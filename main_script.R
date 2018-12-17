rm(list=ls(all=TRUE))

library(sf)
library(tidyverse)
library(mapview)

## Script to process river emissions and GPS data.
## Key datasets test edit

## 1. 365 GPS days. Need lat, lon, and VESSEL_TYPE

## 2. Vessel classifications. vessel_classifications.csv . Gives vessel type, and group.

## 3. The emissions emissions/inventory_export_2016.csv' which are by LAEI exact cut over London

## 4. A shapefile of the grid exact cut

latlong = "+init=epsg:4326"
ukgrid  = "+init=epsg:27700"
google  = "+init=epsg:3857"

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
emissions                 <- left_join(emissions, unique(vessel_class[,c('aggregated_class', 'group')]), by = c('ship_type' = 'aggregated_class'))

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


## Get GPS data 
## list GPS data
list_of_gps_data          <- list.files('gps/', full.names=T, pattern = 'Rdata')

#for (i in 1:length(list_of_gps_data)) {
for (i in 1:5) {
  
  print(paste0('starting ', list_of_gps_data[i]))
  
  load(list_of_gps_data[i])
  
  gps_data                                <- data
  rm(data)
  
  gps_data                                <- st_as_sf(gps_data, coords = c('lon', 'lat'), crs = 4326) %>% 
                                                  st_transform(27700) %>% 
                                                  filter(!is.na(VESSEL_TYPE)) %>%
                                                  left_join(vessel_class, by = c('VESSEL_TYPE' = 'code')) %>%
                                                  select(group)
  
  # Count, over the year in total, how many GPS points there are in each large grid square
  gps_per_grid_id                         <- st_join(gps_data, grid_emissions[,c('id')])
  gps_per_grid_id                         <- data.frame(table(gps_per_grid_id$id))
  names(gps_per_grid_id)                  <- c('grid_id', 'total_daily_gps_count')
  gps_per_grid_id$grid_id                 <- as.integer(gps_per_grid_id$grid_id)
  grid_emissions                          <- left_join(grid_emissions, gps_per_grid_id, by = c("id" = "grid_id"))
  
  if (i == 1) {
    grid_emissions$total_annual_gps_count <- grid_emissions$total_daily_gps_count
    grid_emissions$total_daily_gps_count  <- NULL
    rm(gps_per_grid_id)
  } else {
    grid_emissions$total_annual_gps_count <- grid_emissions$total_annual_gps_count + grid_emissions$total_daily_gps_count
    grid_emissions$total_daily_gps_count  <- NULL
    rm(gps_per_grid_id)   
  }
  
  rm(gps_data)
  
  print(paste0('ended ', list_of_gps_data[i]))
  
}

## At this point code deals with counting all the GPS points inside the large squares but not small ones










## So now make a grid of 50m polygons which are inside the larger polygons
fifty_m_grid    <- st_make_grid(grid_emissions, cellsize = 100, what = 'polygons') %>% st_sf()

# At this point need to count the GPS points instead my smaller polygons
fifty_m_grid$id       <- 1:nrow(fifty_m_grid)
gps_per_small_grid    <- st_join(gps_data, fifty_m_grid[,c('id')])

gps_per_small_grid    <- data.frame(table(gps_per_small_grid$id))



# Now got a grid of polygons insisde the big polygons, the gps data, and the big emission polygons

fifty_m_grid    <- st_join(fifty_m_grid, grid_emissions)

### Right so every cell in the fifty_m_grid has the concentration from the larger grid as 'sailing' or 'berth'

fifty_m_grid    <- fifty_m_grid %>% filter(!is.na(sailing) | !is.na(berth))



## Need to now think about counint points per polygon

gps_data        <- st_join(fifty_m_grid, gps_data)

gps_data        <- gps_data %>% group_by(id) %>% summarise(count = length(pollutant))
