# Mapping the air quality output modelling of the Thames
library(raster)
library(rasterVis)
library(tidyverse)
library(sf)
library(tmap)

data <- raster('E:/apps/LAEI2016/no2.asc')

the_thames <- st_read('https://raw.githubusercontent.com/KCL-ERG/useful_geography/master/thames.geojson')

focus_area                <- st_as_sf(as(raster::extent(529735, 533671, 180049, 181052), 'SpatialPolygons')) %>% 
                              st_set_crs(27700)

focused_data <- raster::crop(data, focus_area)

tmap_mode("plot")
map <- tm_shape(the_thames) +
  tm_polygons(col="white") +
tm_shape(focused_data) +
  tm_raster('no2', palette = "-RdYlBu", alpha = 0.5, title = "NO2 Concentrations")

png("thames_central_no2.png", width=15, height=5, units='cm')
map + tm_layout(outer.margins=0, asp=0)
dev.off()