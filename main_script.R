rm(list=ls(all=TRUE))

library(sf)
library(tidyverse)

## Script to process river emissions and GPS data.
## Key datasets

## 1. 365 GPS days. Need lat, lon, and VESSEL_TYPE

## 2. Vessel classifications. vessel_classifications.csv . Gives vessel type, and group.

## 3. The emissions emissions/inventory_export_2016.csv' which are by LAEI exact cut over London

## 4. A shapefile of the grid exact cut

latlong = "+init=epsg:4326"
ukgrid = "+init=epsg:27700"
google = "+init=epsg:3857"

## Get GPS data for one day of boats
load('gps/Gravesend_ANSData_01_Apr_2016.Rdata')
gps_data                  <- data
rm(data)
gps_data                  <- st_as_sf(gps_data, coords = c('lon', 'lat'), crs = 4326)
gps_data                  <- st_transform(gps_data, 27700)
gps_data                  <- gps_data[!is.na(gps_data$VESSEL_TYPE),]

## Import the ship classifications and link to the gps_data
vessel_class              <- read_csv('docs/vessel_classifications.csv')
vessel_class$code         <- as.character(vessel_class$code)
gps_data                  <- left_join(gps_data, vessel_class, by = c('VESSEL_TYPE' = 'code'))

## Remove data from GPS data that we don't need
gps_data                  <- gps_data[,c('group')]

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
rm(vessel_class)

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

##### SO NOW PAUSING AT THIS POINT WE HAVE THE FOLLOWING
## gps_data       : large number of GPS point, each with a group identifying each type of ship
## grid_emissions : 192 grid exact cuts. When multiplied by pollutants (3), and emission type i.e. 'group', we end up with 1590 grid 'exact cut' polygons.

## Now want to thin things out to see how I get on.
gps_data        <- filter(gps_data, group == 2)                              # Just look at group 2
grid_emissions  <- as.data.frame(grid_emissions) %>% filter(pollutant == 'NOx' & group == 2) %>% st_set_geometry('geom')   # Just look at NOx emissions for group 2

## https://stackoverflow.com/questions/47171710/create-a-grid-inside-a-shapefile

## So now make a grid of points inside each polygon

fifty_m_grid    <- st_make_grid(grid_emissions, cellsize = 50, square = TRUE, what = 'polygons')

fifty_m_grid    <- st_sf(data.frame(value = 1:182000, geom = fifty_m_grid))

fifty_m_grid    <- st_join(x = grid_emissions, y = fifty_m_grid, join = st_touches(), left = TRUE)



             