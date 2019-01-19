rm(list=ls(all=TRUE))

library(sf)
library(tidyverse)
library(scales)
library(snowfall)

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

# Now aggregte
emissions <- emissions %>% 
              select(-ship_type) %>% 
              group_by(pollutant, cellid, group) %>% 
              summarise(sailing = sum(sailing, na.rm=T),
                        berth   = sum(berth, na.rm=T)) %>% 
              ungroup()

# Now get the grid by exact cut
grid                      <- st_read('grids/LAEIGridExtensionV2.gpkg', quiet = T)

# Link grid exact cut to eimssions exact cut, and remove some unncecessary data
grid_emissions            <- left_join(emissions, grid, by = c('cellid' = 'CellID')) %>%
                             rename(large_grid_id = GRID_ID0, x = X_COORD, y = Y_COORD) %>%
                             select(cellid, large_grid_id, x, y, pollutant, group, sailing, berth) %>%
                             as.tibble() %>%
                             group_by(pollutant, group, large_grid_id, x, y) %>%
                             summarise(sailing = sum(sailing), berth = sum(berth)) %>%
                             st_as_sf(coords = c("x", "y"), crs=27700) %>%
                             st_buffer(dist = 500, endCapStyle= "SQUARE")

rm(emissions, grid)

## PLOT OF NOx for group 2
plot <- ggplot() + 
  geom_sf(data = filter(grid_emissions, pollutant == 'NOx' & group == 1), colour = NA, aes(fill = sailing)) + 
  scale_fill_distiller(palette = 'RdYlGn') + 
  ggtitle('Sailing emissions: NOx group 1')
ggsave('large_grid_sailing_group_one_nox.png', plot = plot, path = 'maps/', height = 5, width = 15, units='cm')

plot <- ggplot() + 
  geom_sf(data = filter(grid_emissions, pollutant == 'NOx' & group == 1), colour = NA, aes(fill = berth)) + 
  scale_fill_distiller(palette = 'RdYlGn') + 
  ggtitle('Berth emissions: NOx group 1')
ggsave('large_grid_berth_group_one_nox.png', plot = plot, path = 'maps/', height = 5, width = 15, units='cm')

## For each grid_emissions there is one square per group and per pollutant. More data than we need for the spatial joins with the
## GPS data. So just get unique polygons. Give the unique polygons an ID. Then join these new unique polygon IDs to the full list. Like
## a left join look-up thing

## Setup the small grids
small_grid                         <- unique(grid_emissions[,c('large_grid_id','geometry')]) %>%
                                      st_make_grid(cellsize = 20, what = 'polygons') %>%
                                      st_sf() %>%
                                      st_intersection(unique(grid_emissions[,c('large_grid_id','geometry')])) %>%
                                      mutate(small_grid_id = row_number())

## Make a small  grid results dataset that we'll count the GPS points into
small_grid_result         <- rbind(small_grid %>% mutate(group = 1),
                                   small_grid %>% mutate(group = 2),
                                   small_grid %>% mutate(group = 3),
                                   small_grid %>% mutate(group = 4))

## Get GPS data 
list_of_gps_data             <- list.files('gps/', full.names=T, pattern = 'Rdata')
list_of_gps_data             <- data.frame(filename         = list_of_gps_data,
                                           actual_date      = NA,
                                           stringsAsFactors = F)
list_of_gps_data$actual_date <- substr(x     = list_of_gps_data$filename,
                                       start = 24,
                                       stop  = nchar(list_of_gps_data$filename)-6)
list_of_gps_data$actual_date <- as.Date(list_of_gps_data$actual_date, format = '%d_%b_%Y')
list_of_gps_data             <- list_of_gps_data[order(list_of_gps_data$actual_date),]
list_of_gps_data             <- as.list(list_of_gps_data$filename)

## Function to calculate how many GPS points are within each large square, and within each small grid square

process_gps_data <-  function(x) {
  
  load(x)
  
  gps_data                                <- st_as_sf(data, coords = c('lon', 'lat'), crs = 4326) %>% 
                                                st_transform(27700) %>% 
                                                st_crop(st_bbox(small_grid)) %>%
                                                filter(!is.na(VESSEL_TYPE)) %>%
                                                left_join(vessel_class, by = c('VESSEL_TYPE' = 'code')) %>%
                                                select(group)
  
  rm(data)
  
  # Count, over the year in total, how many GPS points there are in each small grid square

  gps_per_small_grid_id                   <- st_join(gps_data, small_grid, join = st_intersects) %>% 
                                                filter(!is.na(small_grid_id))
  
  # Remove geoms we don't need from this count
  gps_per_small_grid_id$geometry          <- NULL

  # Sum up by the grid square
  gps_per_small_grid_id                   <- gps_per_small_grid_id %>% 
                                                select(group, small_grid_id) %>%
                                                group_by(small_grid_id, group) %>%
                                                summarise(count = length(group))
  
  save(gps_per_small_grid_id, file = paste0('grids/small_result_', substr(x = x,
                                                   start = 24,
                                                   stop = nchar(x)-6), '.Rdata'))
  
  rm(gps_per_small_grid_id)
  
}

# Set-up parallel and fun above function

sfInit(parallel=TRUE, cpus=parallel:::detectCores()-1)
sfLibrary(sf)
sfLibrary(tidyverse)
sfExport(list=list("small_grid", "vessel_class"))
sfLapply(list_of_gps_data, fun=process_gps_data)
sfStop()

## Tidy
rm(process_gps_data, list_of_gps_data)

## Got results for each day in individual data frames. Read them all in, and combine into one data frame

list_of_small_grid_gps_result_data             <- list.files('grids/', full.names=T, pattern = 'small')

for (i in 1:length(list_of_small_grid_gps_result_data)) {
  load(list_of_small_grid_gps_result_data[i])
if (i == 1) {
  gps_per_small_grid_bind <- gps_per_small_grid_id
} else {
  gps_per_small_grid_bind <- bind_rows(gps_per_small_grid_bind,gps_per_small_grid_id)
}
}

# remove some stuff we don't need anymore

rm(list_of_small_grid_gps_result_data, gps_per_small_grid_id, i, small_grid)

# And do the same for the small exact cut grids

gps_per_small_grid        <- gps_per_small_grid_bind %>%
                              group_by(small_grid_id, group) %>% 
                              summarise(count = sum(count))
rm(gps_per_small_grid_bind)

## Now need to join to the result grids I made

small_grid_result         <- left_join(small_grid_result, gps_per_small_grid,
                                       by = c("small_grid_id" = "small_grid_id", "group" = "group"))

rm(gps_per_small_grid)

## Plot of large_grid_id 9886
plot <- ggplot(data=filter(small_grid_result, large_grid_id == 9886)) + 
          geom_sf(aes(fill=count), colour=NA) + 
          facet_wrap(.~group, nrow = 1) + 
          scale_fill_distiller(palette="Spectral", na.value="transparent") +
          ggtitle('Count of annual GPS points in large_grid_id 9886')
ggsave('small_grid_gps_count_9886.png', plot = plot, path = 'maps/', height = 5, width = 15, units='cm')

# Need to do something about the berths now.
#Maybe need to buffer berths to intersect with more small grid squares

berths <- st_read('shapefiles/Berths.shp') %>% select(berth_name) %>% st_set_crs(27700)

small_grid_result <- small_grid_result %>% 
  st_join(berths, join = st_intersects, left = TRUE)

small_grid_result$berth_name <- as.character(small_grid_result$berth_name)

## remove data where there's less than 20 GPS points
small_grid_result    <- filter(small_grid_result, count > 20)

##
large_grid_sailing_counts <- aggregate(data=small_grid_result[!is.na(small_grid_result$count) & is.na(small_grid_result$berth_name),],  count ~ group + large_grid_id, FUN=sum)
large_grid_berth_counts   <- aggregate(data=small_grid_result[!is.na(small_grid_result$count) & !is.na(small_grid_result$berth_name),], count ~ group + large_grid_id, FUN=sum)

names(large_grid_sailing_counts)[3] <- 'sailing_count'
names(large_grid_berth_counts)[3]   <- 'berth_count'

small_grid_result <- small_grid_result %>% left_join(large_grid_sailing_counts, by = c("large_grid_id" = "large_grid_id",
                                                                                      "group" = "group")) %>%
                                          left_join(large_grid_berth_counts,   by = c("large_grid_id" = "large_grid_id",
                                                                                      "group" = "group"))

rm(large_grid_sailing_counts, large_grid_berth_counts)

# Calculate the contribution percentages
small_grid_result$contribution <- NA

small_grid_result[is.na(small_grid_result$berth_name),'contribution'] <-  small_grid_result[is.na(small_grid_result$berth_name),]$count / 
                                                                          small_grid_result[is.na(small_grid_result$berth_name),]$sailing_count

small_grid_result[!is.na(small_grid_result$berth_name),'contribution'] <- small_grid_result[!is.na(small_grid_result$berth_name),]$count / 
                                                                          small_grid_result[!is.na(small_grid_result$berth_name),]$berth_count

small_grid_result    <-   rbind(small_grid_result %>% mutate(pollutant = 'NOx'),
                                small_grid_result %>% mutate(pollutant = 'PM'),
                                small_grid_result %>% mutate(pollutant = 'PM2.5'))

grid_emissions$geometry <- NULL

small_grid_result         <-  left_join(small_grid_result, grid_emissions, by = c("large_grid_id" = "large_grid_id",
                                                                                  "group" = "group",
                                                                                 "pollutant" = "pollutant"))

small_grid_result$emissions <- NA

small_grid_result[is.na(small_grid_result$berth_name),'emissions'] <-  small_grid_result[is.na(small_grid_result$berth_name),]$contribution *
                                                                             small_grid_result[is.na(small_grid_result$berth_name),]$sailing

small_grid_result[!is.na(small_grid_result$berth_name),'emissions'] <-  small_grid_result[!is.na(small_grid_result$berth_name),]$contribution *
                                                                              small_grid_result[!is.na(small_grid_result$berth_name),]$berth


#################################
#################################
## PLOTTING

st_write(small_grid_result, 'temp/small_grid_result.shp')


