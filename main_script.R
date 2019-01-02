rm(list=ls(all=TRUE))

library(sf)
library(tidyverse)
library(mapview)
library(scales)
library(viridis)
library(gridExtra)

## Script to process river emissions and GPS data.
## Key datasets test edit

## 1. 365 GPS days. Need lat, lon, and VESSEL_TYPE

## 2. Vessel classifications. vessel_classifications.csv . Gives vessel type, and group.

## 3. The emissions emissions/inventory_export_2016.csv' which are by LAEI exact cut over London

## 4. A shapefile of the grid exact cut

latlong = "+init=epsg:4326"
ukgrid  = "+init=epsg:27700"
google  = "+init=epsg:3857"

the_thames <- st_read('https://raw.githubusercontent.com/KCL-ERG/useful_geography/master/thames.geojson')

## Import the ship classifications 
vessel_class              <- read_csv('docs/vessel_classifications.csv')
vessel_class$code         <- as.character(vessel_class$code)

# Get emissions by exact cut, substance and vessel type
emissions                 <- read_csv('emissions/inventory_export_2016.csv', col_types = cols())
emissions                 <- emissions[emissions$LAEIPLAExt == 'LAEI',]
emissions                 <- emissions[,c('VesselType', 'Substance', 'CellID', 'Sailing_kg', 'AtBerth_kg')]
emissions$CellID          <- as.numeric(emissions$CellID)
names(emissions)          <- c('ship_type', 'pollutant', 'cellid', 'sailing', 'berth')
pollutants_we_want        <- c('PM', 'PM2.5', 'NOx')
emissions                 <- emissions[emissions$pollutant %in% pollutants_we_want,]
rm(pollutants_we_want)

# Tidy up some of the vessel classifications in the emissions file to match the GPS ecssel types
emissions[emissions$ship_type == 'RoRo Cargo / Vehicle','ship_type'] <-'RoRo Cargo/Vehicle'
emissions[emissions$ship_type == 'Cruise ship','ship_type']          <-'Passenger (cruise)'
emissions[emissions$ship_type == 'Passenger', 'ship_type']           <-'Passenger (ferry)'

# Add vessel group type to the emissions, for matching with GPS data
emissions                 <- left_join(emissions, unique(vessel_class[,c('aggregated_class', 'group')]),
                                       by = c('ship_type' = 'aggregated_class'))

# Now get the grid by exact cut
grid                      <- st_read('grids/LAEIGridExtensionV2.gpkg', quiet = T)
grid                      <- grid[grid$LAEIPLAExt == 'LAEI',]
grid                      <- grid[,c('GRID_ID0', 'CellID')]
names(grid)               <- c('gridid', 'cellid', 'geom')

# Link grid exact cut to eimssions exact cut, and remove some unncecessary data
grid_emissions            <- left_join(emissions, grid, by = c('cellid' = 'cellid'))
grid_emissions            <- st_set_geometry(grid_emissions, grid_emissions$geom)
grid_emissions$ship_type  <- NULL
grid_emissions$cellid     <- NULL
grid_emissions$gridid     <- NULL

rm(emissions, grid)

# The emissions are split by ship_type, but we can do it by 'group' instead. So need to aggregate .
grid_emissions$geom_group <- sapply(st_equals(grid_emissions), max)

grid_emissions            <- grid_emissions %>%
                              group_by(geom_group, pollutant, group) %>%
                              summarise(sailing = sum(sailing),
                              berth   = sum(berth))

grid_emissions$geom_group <- NULL
grid_emissions$id         <- 1:nrow(grid_emissions) 

## For each grid_emissions there is one square per group and per pollutant. More data than we need for the spatial joins with the
## GPS data. So just get unique polygons. Give the unique polygons an ID. Then join these new unique polygon IDs to the full list. Like
## a left join look-up thing

unique_geoms                <- unique(grid_emissions[,'geom'])
unique_geoms$unique_geom_id <- 1:nrow(unique_geoms) 
grid_emissions              <- st_join(grid_emissions, unique_geoms, join = st_equals)

## Unique geoms results
unique_geoms_result         <- rbind(unique_geoms %>% mutate(group = 1),
                                     unique_geoms %>% mutate(group = 2),
                                     unique_geoms %>% mutate(group = 3),
                                     unique_geoms %>% mutate(group = 4))

## Setup the small grids
small_grid                     <- st_make_grid(unique_geoms, cellsize = 100, what = 'polygons') %>% st_sf()
small_grid$small_grid_id       <- 1:nrow(small_grid) 
small_grid$geometry_centroid   <- st_geometry(st_centroid(small_grid))
small_grid                     <- st_set_geometry(small_grid, 'geometry_centroid')
small_grid                     <- st_join(small_grid, unique_geoms, join = st_intersects) %>% 
  filter(!is.na(unique_geom_id))
small_grid                     <- st_set_geometry(small_grid, 'geometry')
small_grid$geometry_centroid   <- NULL

## small grid results
small_grid_result         <- rbind(small_grid %>% mutate(group = 1),
                                   small_grid %>% mutate(group = 2),
                                   small_grid %>% mutate(group = 3),
                                   small_grid %>% mutate(group = 4))

## Get GPS data 
## list GPS data
list_of_gps_data             <- list.files('gps/', full.names=T, pattern = 'Rdata')

list_of_gps_data             <- data.frame(filename    = list_of_gps_data,
                                        actual_date = NA,
                                        stringsAsFactors = F)

list_of_gps_data$actual_date <- substr(x = list_of_gps_data$filename,
                                       start = 23,
                                       stop = nchar(list_of_gps_data$filename)-6)

list_of_gps_data$actual_date <- as.Date(list_of_gps_data$actual_date, format = '%d_%b_%Y')

list_of_gps_data             <- list_of_gps_data[order(list_of_gps_data$actual_date),]

## Calculate how many GPS points are within each large square (need that to do the proportions)
## Needs editing so that does it by 'group'. Might want to look at st_equals_exact

for (i in 1:nrow(list_of_gps_data)) {

  print(paste0('starting ', list_of_gps_data[i,]$actual_date, ' at ', Sys.time()))
  
  load(list_of_gps_data[i,]$filename)
  
  gps_data                                <- st_as_sf(data, coords = c('lon', 'lat'), crs = 4326) %>% 
                                                  st_transform(27700) %>% 
                                                  st_crop(st_bbox(unique_geoms)) %>%
                                                  filter(!is.na(VESSEL_TYPE)) %>%
                                                  left_join(vessel_class, by = c('VESSEL_TYPE' = 'code')) %>%
                                                  select(group)
  
  rm(data)
  
  # Count, over the year in total, how many GPS points there are in each large grid square
  gps_per_grid_id                         <- st_join(gps_data, unique_geoms, join = st_intersects) %>% 
                                             filter(!is.na(unique_geom_id))
  
  gps_per_small_grid_id                   <- st_join(gps_data, small_grid, join = st_intersects) %>% 
                                              filter(!is.na(unique_geom_id))
  
  # Remove geoms we don't need from this count
  gps_per_grid_id$geometry                <- NULL
  gps_per_small_grid_id$geometry          <- NULL
  
  # Sum up by the grid square
  gps_per_grid_id                         <- gps_per_grid_id %>%
                                              group_by(unique_geom_id, group) %>%
                                              summarise(count = length(group))
  
  gps_per_small_grid_id                   <- gps_per_small_grid_id %>% 
                                              group_by(small_grid_id, group) %>%
                                              summarise(count = length(group))
  
  # Add them to the result data                                              
  unique_geoms_result                     <- left_join(unique_geoms_result, gps_per_grid_id,
                                                       by = c("unique_geom_id" = "unique_geom_id",
                                                              "group" = "group"))
  
  small_grid_result             <- left_join(small_grid_result, gps_per_small_grid_id,
                                             by = c("small_grid_id" = "small_grid_id",
                                                    "group" = "group"))
  
  # Depending on if it's the first time or not
  
  if (i == 1) {
    
    unique_geoms_result$total_annual_gps_count <- unique_geoms_result$count
    unique_geoms_result$count                  <- NULL
    rm(gps_per_grid_id)
    
    small_grid_result$total_annual_gps_count <- small_grid_result$count
    #small_grid_result$count                  <- NULL
    rm(gps_per_small_grid_id)
    
  } else {
    
    unique_geoms_result$total_annual_gps_count <- unique_geoms_result$total_annual_gps_count + unique_geoms_result$count
    unique_geoms_result$count                  <- NULL
    rm(gps_per_grid_id) 
    
    small_grid_result$total_annual_gps_count <- small_grid_result$total_annual_gps_count + small_grid_result$count
    #small_grid_result$count                  <- NULL
    rm(gps_per_small_grid_id)
    
  }
  
  
  print(paste0('ended ', list_of_gps_data[i,]$actual_date, ' at ', Sys.time()))
  
  facet_labels <- c('1' = 'Group One',
                    '2' = 'Group Two',
                    '3' = 'Group Three',
                    '4' = 'Group Four')
  
  if (i == 1) {points_counter <- nrow(gps_data) } else {
    points_counter <- points_counter + nrow(gps_data)
  }
  
  plot <- ggplot() + 
    geom_sf(data = the_thames, fill='grey', colour = NA, alpha=0.2) +
    geom_sf(data=filter(small_grid_result, !is.na(count)), aes(fill = as.factor(group)), colour=NA) +
    facet_wrap(.~group, ncol = 1, labeller = as_labeller(facet_labels)) +
    theme(axis.ticks = element_blank(),
          axis.text  = element_blank(),
          panel.background = element_blank(),
          strip.background = element_blank(),
          strip.text.x = element_text(size = 16),
          legend.position = 'none',
          plot.title = element_text(size = 16, face = "bold", hjust=0.5)) +
    ggtitle(paste0('Day ', i, 
                  ' - ',
                  nrow(gps_data),
                  ' GPS points')) +
    xlab(paste0('Total points processed = ', points_counter))
  
  png(filename = paste0('animation_pics/', 
                        list_of_gps_data[i,]$actual_date,
                        '.png'), width = 14, height = 20, units = 'cm', res = 200)
  print(plot)
  dev.off()
  
  small_grid_result$count                  <- NULL
  
  rm(gps_data)
  
  save(small_grid_result, file = 'small_grid_result.Rdata')
  save(unique_geoms_result, file = 'unique_geoms_result.Rdata')
  
}

#############
