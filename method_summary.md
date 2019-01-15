# Method summary

## Emissions
PLA 2016 emissions covering London are imported as a [CSV](https://github.com/JimShady/laei_river_data/blob/master/emissions/inventory_export_2016.csv). These contain for each pollutant, ship type and cellid (LAEI exact cut) the estimated shipping emissions in kg per annum for that area (approx. 1km x 1km). There are 12 ship types in the inventory, however these are grouped by [vessel class](https://github.com/JimShady/laei_river_data/blob/master/docs/vessel_classifications.csv) (also provided by PLA) to 4 types. Henceforth known as `Group 1`, `Group 2`, `Group 3` and `Group 4`. This data is now joined to a geopackage of the LAEI grid exact cuts using the `cellid` identifier. A map (of NO2) and view of the data is shown below.

```r
Simple feature collection with 12 features and 6 fields
geometry type:  POLYGON
dimension:      XY
bbox:           xmin: 555000 ymin: 177000 xmax: 556000 ymax: 178000
epsg (SRID):    27700
proj4string:    +proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +towgs84=446.448,-125.157,542.06,0.15,0.247,0.842,-20.489 +units=m +no_defs
   pollutant group    sailing        berth id unique_geom_id                           geom
1        NOx     1   54.58000 0.000000e+00  1              1 POLYGON ((555000 178000, 55...
2        NOx     2 6778.18000 2.090000e+00  2              1 POLYGON ((555000 178000, 55...
3        NOx     3 1428.70000 0.000000e+00  3              1 POLYGON ((555000 178000, 55...
4        NOx     4 3969.60000 4.567010e+03  4              1 POLYGON ((555000 178000, 55...
5         PM     1    1.50260 0.000000e+00  5              1 POLYGON ((555000 178000, 55...
6         PM     2  285.13240 3.556416e-02  6              1 POLYGON ((555000 178000, 55...
7         PM     3   38.85676 0.000000e+00  7              1 POLYGON ((555000 178000, 55...
8         PM     4  190.49544 1.415743e+02  8              1 POLYGON ((555000 178000, 55...
9      PM2.5     1    1.42747 0.000000e+00  9              1 POLYGON ((555000 178000, 55...
10     PM2.5     2  270.87578 3.378595e-02 10              1 POLYGON ((555000 178000, 55...
11     PM2.5     3   36.91392 0.000000e+00 11              1 POLYGON ((555000 178000, 55...
12     PM2.5     4  180.97067 1.344956e+02 12              1 POLYGON ((555000 178000, 55...
```

![Map of NO2 emissions](https://github.com/JimShady/laei_river_data/blob/master/maps/large_grid_sailing.png)

## The 20m grid
A 20m x 20m polygon grid (`small_grid`) covering the extent of the emission grid was now created. This was then intersected and clipped with a unique geographical representation of the emissions grid i.e. just one cell for each emission area, rather than twelve cells (3 pollutants x 4 groups). A `unique_geom_id` column was added to the `small_grid`, to enable linking of the `small_grid` back to the original emissions. Some of the data, and a section of the grid are shown below.

```r
Simple feature collection with 305920 features and 2 fields
geometry type:  GEOMETRY
dimension:      XY
bbox:           xmin: 523000 ymin: 174000 xmax: 558000 ymax: 187000
epsg (SRID):    27700
proj4string:    +proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +towgs84=446.448,-125.157,542.06,0.15,0.247,0.842,-20.489 +units=m +no_defs
First 10 features:
   unique_geom_id                       geometry small_grid_id
1               1 POLYGON ((555000 177020, 55...             1
2               1 POLYGON ((555000 177000, 55...             2
3               1 POLYGON ((555020 177000, 55...             3
4               1 POLYGON ((555040 177000, 55...             4
5               1 POLYGON ((555060 177000, 55...             5
6               1 POLYGON ((555080 177000, 55...             6
7               1 POLYGON ((555100 177000, 55...             7
8               1 POLYGON ((555120 177000, 55...             8
9               1 POLYGON ((555140 177000, 55...             9
10              1 POLYGON ((555160 177000, 55...            10
```

![Map of small grid](https://github.com/JimShady/laei_river_data/blob/master/maps/small_grid.png)

## Processing AIS data
366 days of AIS data for 2016 were provided by the PLA. These were processed using the Python [libais library](https://github.com/schwehr/libais) to extract the `latitude`, `longitude` and `ship_type (group)`, and the data exported as an R Dataframe. A sample is shown below.

```r
        lon      lat VESSEL_TYPE
1 0.3968550 51.44474         XTG
2 0.3413600 51.46286         GPC
3 0.3268333 51.45400         GGC
4 0.2523367 51.46938         URR
5 0.3962933 51.44480         XTG
6 0.3494783 51.45776         GPC
```

## Counting GPS points
The AIS data was imported in turn, and spatially joined to the `small_grid`. The result being that each `small_grid` contained the count of the total number of GPS points, per ship group, that had been recorded in that grid square. The map and data below show the annual count of GPS points within each grid square.

```r
Simple feature collection with 131888 features and 4 fields
geometry type:  GEOMETRY
dimension:      XY
bbox:           xmin: 523860 ymin: 174420 xmax: 558000 ymax: 186900
epsg (SRID):    27700
proj4string:    +proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +towgs84=446.448,-125.157,542.06,0.15,0.247,0.842,-20.489 +units=m +no_defs
First 10 features:
   unique_geom_id small_grid_id group count                       geometry
1               1            40     1     3 POLYGON ((555760 177000, 55...
2               1            41     1     1 POLYGON ((555780 177000, 55...
3               1            44     1     2 POLYGON ((555840 177000, 55...
4               1            46     1     7 POLYGON ((555880 177000, 55...
5               1            47     1    12 POLYGON ((555900 177000, 55...
6               1            48     1     6 POLYGON ((555920 177000, 55...
7               1            49     1    11 POLYGON ((555940 177000, 55...
8               1            50     1     4 POLYGON ((555960 177000, 55...
9               1            51     1    10 POLYGON ((555980 177000, 55...
10              1            88     1     1 POLYGON ((555700 177020, 55...
```

![Map of small grid](https://github.com/JimShady/laei_river_data/blob/master/maps/small_grid_gps_count.png)

## Berths
The PLA 2016 emissions are split between `sailing` and `berth`. The berth emissions will be distributed to the berths that are within each `cellid`, weighted by the number of GPS points within the `small_grid` cell of the berth. A shapefile of berths was therefore imported, and joined to the small grid, adding an extra column to identify if that small_grid cell held a berth or not. The result of this is shown below as data and a map.

```r
Simple feature collection with 448 features and 5 fields
geometry type:  GEOMETRY
dimension:      XY
bbox:           xmin: 525600 ymin: 175520 xmax: 557800 ymax: 182900
epsg (SRID):    27700
proj4string:    +proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +towgs84=446.448,-125.157,542.06,0.15,0.247,0.842,-20.489 +units=m +no_defs
First 10 features:
   unique_geom_id small_grid_id group count                                  berth_name                       geometry
1               1           913     1     2                                      Esso 1 POLYGON ((555880 177340, 55...
2               1          1662     1    NA   Powell Duffryn Terminals Ltd - No.7 Lower POLYGON ((555560 177640, 55...
3               1          1811     1    NA   Powell Duffryn Terminals Ltd - Main Jetty POLYGON ((555480 177700, 55...
4               1          1814     1    NA   Powell Duffryn Terminals Ltd - No.4 Lower POLYGON ((555540 177700, 55...
5               1          1913     1    NA  Powell Duffryn Terminals Ltd - No.5 Middle POLYGON ((555480 177740, 55...
6               1          1961     1    NA Powell Duffryn Terminals Ltd - No.2/3 Upper POLYGON ((555420 177760, 55...
7               1          2014     1    NA   Powell Duffryn Terminals Ltd - No.6 Upper POLYGON ((555460 177780, 55...
8               2          2867     1    NA                 Purfleet Deep Water - Upper POLYGON ((556180 177120, 55...
9               2          3065     1    NA                           Esso No.2 - Lower POLYGON ((556060 177200, 55...
10              4          8599     1    NA            Littlebrook Power Station - Main POLYGON ((556580 176300, 55...
```

![Map of PLA berths](https://github.com/JimShady/laei_river_data/blob/master/maps/berths.png)

## Distributing emissions
The totals for each large grid were now calculated, and joined back to the small grid. Then the count of GPS points in each 20m by 20m grid, was divided by the total of GPS points within the larger grid (1km by 1km) for that area, to give a weighting for each small grid to draw down the emissions. The grid cells containing berths were calculated in a similar manner but indenpendantly i.e. only cells that contained berths were divided by the berth_count.

```r
Simple feature collection with 131888 features and 8 fields
geometry type:  GEOMETRY
dimension:      XY
bbox:           xmin: 523860 ymin: 174420 xmax: 558000 ymax: 186900
epsg (SRID):    27700
proj4string:    +proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +towgs84=446.448,-125.157,542.06,0.15,0.247,0.842,-20.489 +units=m +no_defs
First 10 features:
   unique_geom_id small_grid_id group gps_count berth_name sailing_count berth_count contribution                       geometry
1               1            40     1         3       <NA>          8271           2 0.0003627131 POLYGON ((555760 177000, 55...
2               1            41     1         1       <NA>          8271           2 0.0001209044 POLYGON ((555780 177000, 55...
3               1            44     1         2       <NA>          8271           2 0.0002418087 POLYGON ((555840 177000, 55...
4               1            46     1         7       <NA>          8271           2 0.0008463306 POLYGON ((555880 177000, 55...
5               1            47     1        12       <NA>          8271           2 0.0014508524 POLYGON ((555900 177000, 55...
6               1            48     1         6       <NA>          8271           2 0.0007254262 POLYGON ((555920 177000, 55...
7               1            49     1        11       <NA>          8271           2 0.0013299480 POLYGON ((555940 177000, 55...
8               1            50     1         4       <NA>          8271           2 0.0004836175 POLYGON ((555960 177000, 55...
9               1            51     1        10       <NA>          8271           2 0.0012090436 POLYGON ((555980 177000, 55...
10              1            88     1         1       <NA>          8271           2 0.0001209044 POLYGON ((555700 177020, 55...
```

The small_grid was now duplicated 3 times, a pollutant column added to each and populated (PM2.5, NOx and PM), and then joined back together again. It was then joined to the emissions by `pollutant`, `group` and `unique_geom_id`. Subsequently the `contribution` was multiplied by the emission for that large grid square, and stored as `emissions`. A map of NOx emissions for group 2 is shown below.

INSERT MAP HERE.

## Large grids with no GPS data
Now have a problem though, as there are 1km by 1km emission grid areas from the PLA, with emissions for sailing/berth, where there is no GPS data. So the small grid squares in those areas have a `contribution` of 0 and can't distribute the emissions. For example `unique_geom_id` area 11 has the below emissions.

```r
Simple feature collection with 3 features and 6 fields
geometry type:  POLYGON
dimension:      XY
bbox:           xmin: 545000 ymin: 182000 xmax: 546000 ymax: 183000
epsg (SRID):    27700
proj4string:    +proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +towgs84=446.448,-125.157,542.06,0.15,0.247,0.842,-20.489 +units=m +no_defs
  pollutant group    sailing berth id unique_geom_id                           geom
1       NOx     2 0.48000000     0 76             11 POLYGON ((545425.6 182000, ...
2        PM     2 0.01464797     0 78             11 POLYGON ((545425.6 182000, ...
3     PM2.5     2 0.01391557     0 80             11 POLYGON ((545425.6 182000, ...
```

But there are no GPS points for category 1 or 2 within it.

```r
Simple feature collection with 1806 features and 4 fields
geometry type:  POLYGON
dimension:      XY
bbox:           xmin: 545000 ymin: 182000 xmax: 546000 ymax: 183000
epsg (SRID):    27700
proj4string:    +proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +towgs84=446.448,-125.157,542.06,0.15,0.247,0.842,-20.489 +units=m +no_defs
First 10 features:
   unique_geom_id small_grid_id group count                       geometry
1              11         24362     2    NA POLYGON ((545427.2 182020, ...
2              11         24363     2    NA POLYGON ((545440 182000, 54...
3              11         24364     2    NA POLYGON ((545460 182000, 54...
4              11         24365     2    NA POLYGON ((545480 182000, 54...
5              11         24366     2    NA POLYGON ((545500 182000, 54...
6              11         24367     2    NA POLYGON ((545520 182000, 54...
7              11         24368     2    NA POLYGON ((545540 182000, 54...
8              11         24369     2    NA POLYGON ((545560 182000, 54...
9              11         24370     2    NA POLYGON ((545580 182000, 54...
10             11         24371     2    NA POLYGON ((545600 182000, 54...
```
![No GPS issue](https://github.com/JimShady/laei_river_data/blob/master/maps/no_gps_issue.png)

There are other areas like this. MAKE MAP.

