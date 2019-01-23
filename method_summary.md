# Method summary

## Ship types
There are 12 ship types in the inventory, known as vessel classifications. These are imported from a [CSV](https://github.com/JimShady/laei_river_data/blob/master/docs/vessel_classifications.csv) provided by PLA. A sample is shown below.

```r
# A tibble: 67 x 6
   registry_class                           aggregated_class        group code  release_height fuel_type
   <chr>                                    <chr>                   <dbl> <chr>          <dbl> <chr>    
 1 ferry                                    Passenger (ferry)           1 OFY              5   Diesel   
 2 cutter suction dredger                   Dredger                     2 DCS             17.5 Diesel   
 3 dredger                                  Dredger                     2 DDR             17.5 Diesel   
 4 hopper dredger                           Dredger                     2 DHD             17.5 Diesel   
 5 suction hopper dredger                   Dredger                     2 DSH             17.5 Diesel   
 6 sand suction dredger                     Dredger                     2 DSS             17.5 Diesel   
 7 trailing suction dredger                 Dredger                     2 DTD             17.5 Diesel   
 8 trailing suction hopper dredger          Dredger                     2 DTS             17.5 Diesel   
 9 fishing (general)                        Fishing                     2 FFS             17.5 Diesel   
10 trawler (All types)                      Fishing                     2 FTR             17.5 Diesel   
```

Each type of ship has a `code` and `group`. There are four groups.

## Emissions

PLA 2016 emissions covering London are imported as a [CSV](https://github.com/JimShady/laei_river_data/blob/master/emissions/inventory_export_2016.csv). These contain for each pollutant, ship type and cellid (LAEI exact cut) the estimated shipping emissions in kg per annum for that area (approx. 1km x 1km). A sample is shown below.

```r
# A tibble: 3,159 x 5
   ship_type    pollutant cellid sailing berth
   <chr>        <chr>      <dbl>   <dbl> <dbl>
 1 Bulk carrier NOx         1584   41.8      0
 2 Bulk carrier NOx          911   22.6      0
 3 Bulk carrier NOx          907    0.5      0
 4 Bulk carrier NOx         2211    9.53     0
 5 Bulk carrier NOx         2205   49.8      0
 6 Bulk carrier NOx         2246   10.5      0
 7 Bulk carrier NOx          860   72.9      0
 8 Bulk carrier NOx         2208   68.5      0
 9 Bulk carrier NOx         2212    2.99     0
10 Bulk carrier NOx         1587   40.7      0
```

The [`vessel_classifications`](https://github.com/JimShady/laei_river_data/blob/master/docs/vessel_classifications.csv) are joined to the [`inventory_export_2016.csv`](https://github.com/JimShady/laei_river_data/blob/master/emissions/inventory_export_2016.csv) by `ship_type`. However there are three `ship_type`'s in the emissions that do not exactly match with the `vessel_classifications` file. These are edited to force them to link, as below.

|Emissions ship_type    |Vessel classification ship_type|
|:---------------------:|:-----------------------------:|
|'RoRo Cargo / Vehicle' |     'RoRo Cargo/Vehicle'      |
|    'Cruise ship'      |     'Passenger (cruise)'      |
|    'Passenger'        |     'Passenger (ferry)'       |

The emissions now look like this:

```r
# A tibble: 3,159 x 6
   ship_type    pollutant cellid sailing berth group
   <chr>        <chr>      <dbl>   <dbl> <dbl> <dbl>
 1 Bulk carrier NOx         1584   41.8      0     3
 2 Bulk carrier NOx          911   22.6      0     3
 3 Bulk carrier NOx          907    0.5      0     3
 4 Bulk carrier NOx         2211    9.53     0     3
 5 Bulk carrier NOx         2205   49.8      0     3
 6 Bulk carrier NOx         2246   10.5      0     3
 7 Bulk carrier NOx          860   72.9      0     3
 ```
 
 Using the `group`, `pollutant` and `cellid` columns they are now grouped to give the below.
 
 ```r
 # A tibble: 1,590 x 5
   pollutant cellid group  sailing    berth
   <chr>      <dbl> <dbl>    <dbl>    <dbl>
 1 NOx          231     1    54.6      0   
 2 NOx          231     2  6778.       2.09
 3 NOx          231     3  1429.       0   
 4 NOx          231     4  3970.    4567.  
 5 NOx          232     1     3.35     0   
 6 NOx          232     2   521.       1.54
 7 NOx          232     3    95.7      0   
 8 NOx          232     4 10367.   29460.  
 9 NOx          234     1     2.28     0   
10 NOx          234     2   332.       0 
```

This data is now joined to a geopackage of the LAEI grid exact cuts using the `cellid` identifier. Then the LAEI exact cuts are dissolved to create regular 1km by 1km grids n.b. this is not a spatial aggregate, actually the grid centroid coordinates are used to create the grids, and then linked. The data (`grid_emissions`) now looks like this:

```r
Simple feature collection with 933 features and 5 fields
geometry type:  POLYGON
dimension:      XY
bbox:           xmin: 523000 ymin: 174000 xmax: 558000 ymax: 187000
epsg (SRID):    27700
proj4string:    +proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +towgs84=446.448,-125.157,542.06,0.15,0.247,0.842,-20.489 +units=m +no_defs
# A tibble: 933 x 6
   pollutant group large_grid_id  sailing berth                                                                      geometry
   <chr>     <dbl>         <dbl>    <dbl> <dbl>                                                                 <POLYGON [m]>
 1 NOx           1          9559     0.17  0    ((548000 183000, 548000 182000, 547000 182000, 547000 183000, 548000 183000))
 2 NOx           1          9717     0.26  0    ((534000 182000, 534000 181000, 533000 181000, 533000 182000, 534000 182000))
 3 NOx           1          9728    20.9   0    ((545000 182000, 545000 181000, 544000 181000, 544000 182000, 545000 182000))
 4 NOx           1          9729    82.8   0.01 ((546000 182000, 546000 181000, 545000 181000, 545000 182000, 546000 182000))
 5 NOx           1          9730    62.9   0    ((547000 182000, 547000 181000, 546000 181000, 546000 182000, 547000 182000))
 6 NOx           1          9731    59.4   0    ((548000 182000, 548000 181000, 547000 181000, 547000 182000, 548000 182000))
 7 NOx           1          9732   108.    0    ((549000 182000, 549000 181000, 548000 181000, 548000 182000, 549000 182000))
 8 NOx           1          9733    45.4   0    ((550000 182000, 550000 181000, 549000 181000, 549000 182000, 550000 182000))
 9 NOx           1          9734     9.8   0    ((551000 182000, 551000 181000, 550000 181000, 550000 182000, 551000 182000))
10 NOx           1          9886 22179.   34.1  ((531000 181000, 531000 180000, 530000 180000, 530000 181000, 531000 181000))
# ... with 923 more rows
```
![NOx berth group 1](https://github.com/JimShady/laei_river_data/blob/master/maps/large_grid_berth_group_one_nox.png)

![NOx sailing group 1](https://github.com/JimShady/laei_river_data/blob/master/maps/large_grid_sailing_group_one_nox.png)

## The 20m grid
A 20m x 20m polygon grid (`small_grid`) covering the extent of the `grid_emissions` was now created. This was then intersected and clipped with a unique geographical representation of the emissions grid i.e. just one cell for each emission area, rather than twelve cells (3 pollutants x 4 groups). The link between the `small_grid` and the `grid_emissions` is by `large_grid_id`.The `small_grid` data looks like this:

```r
Simple feature collection with 334932 features and 2 fields
geometry type:  GEOMETRY
dimension:      XY
bbox:           xmin: 523000 ymin: 174000 xmax: 558000 ymax: 187000
epsg (SRID):    27700
proj4string:    +proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +towgs84=446.448,-125.157,542.06,0.15,0.247,0.842,-20.489 +units=m +no_defs
First 10 features:
   large_grid_id small_grid_id                       geometry
1           9559             1          POINT (547000 182000)
2           9559             2 LINESTRING (547020 182000, ...
3           9559             3 LINESTRING (547040 182000, ...
4           9559             4 LINESTRING (547060 182000, ...
5           9559             5 LINESTRING (547080 182000, ...
6           9559             6 LINESTRING (547100 182000, ...
7           9559             7 LINESTRING (547120 182000, ...
8           9559             8 LINESTRING (547140 182000, ...
9           9559             9 LINESTRING (547160 182000, ...
10          9559            10 LINESTRING (547180 182000, ...
```

![Map of small grid](https://github.com/JimShady/laei_river_data/blob/master/maps/small_grid_example.png)

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
On 1 January 2016 (taken as an example day) there were 1,368,454 GPS points in the dataset, 336,967 (25%) of which had no category. The remaining categories and counts are as below. 

```r
   BBU    BCE    BWC    DTD    DTS    GGC    GPC    OFY    OSU    OYT    PRR    RSR    TCO    TEO    TPD    URR    XFF    XTG 
112277  21895  97107  43833   3207  30064  17034 116524  43235  16190  26679  53785  82291  17810   4055  44135  42119 259246
```
## Counting GPS points
The AIS data was imported in turn, and spatially joined to the `small_grid` to create the `small_grid_result`. This being that each `small_grid` contained the count of the total number of GPS points, per `group`, that had been recorded in that grid square over 2016.  The map and data below show the annual count of GPS points within each grid square.

```r
Simple feature collection with 1223680 features and 5 fields
geometry type:  GEOMETRY
dimension:      XY
bbox:           xmin: 523000 ymin: 174000 xmax: 558000 ymax: 187000
epsg (SRID):    27700
proj4string:    +proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +towgs84=446.448,-125.157,542.06,0.15,0.247,0.842,-20.489 +units=m +no_defs
First 10 features:
   cellid small_grid_id group count berth_name                       geometry
1     231             1     1    NA       <NA> POLYGON ((555000 177020, 55...
2     231             2     1    NA       <NA> POLYGON ((555000 177000, 55...
3     231             3     1    NA       <NA> POLYGON ((555020 177000, 55...
4     231             4     1    NA       <NA> POLYGON ((555040 177000, 55...
5     231             5     1    NA       <NA> POLYGON ((555060 177000, 55...
6     231             6     1    NA       <NA> POLYGON ((555080 177000, 55...
7     231             7     1    NA       <NA> POLYGON ((555100 177000, 55...
8     231             8     1    NA       <NA> POLYGON ((555120 177000, 55...
9     231             9     1    NA       <NA> POLYGON ((555140 177000, 55...
10    231            10     1    NA       <NA> POLYGON ((555160 177000, 55...
```

![Map of small grid GPS counts](https://github.com/JimShady/laei_river_data/blob/master/maps/small_grid_gps_count_example.png)

## Berths
The `grid_emissions` are split between `sailing` and `berth`. The berth emissions will be distributed to the berths that are within each `large_grid_id`, weighted by the number of GPS points within the `small_grid` cell of the berth. A [`berths.shp`](https://github.com/JimShady/laei_river_data/blob/master/shapefiles/Berths.shp) was therefore imported, and joined to the `small_grid`, adding an extra column to identify if that cell held a berth or not. The berths data looked like this

```r
Simple feature collection with 180 features and 1 field
geometry type:  POINT
dimension:      XY
bbox:           xmin: -1.797693e+308 ymin: -1.797693e+308 xmax: 589000 ymax: 183040
epsg (SRID):    27700
proj4string:    +proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +towgs84=446.448,-125.157,542.06,0.15,0.247,0.842,-20.489 +units=m +no_defs
First 10 features:
             berth_name              geometry
1     Tower Stairs Tier POINT (533225 180490)
2   St Katharine's Dock POINT (533875 180325)
3        President Quay POINT (533970 180200)
4         Express Wharf POINT (537000 179700)
5       West India Lock POINT (538320 179920)
6            Pura Foods POINT (539060 180660)
7         Orchard Wharf POINT (539230 180710)
8          Thames Wharf POINT (539600 180500)
9  Royal Primrose Works POINT (540200 179850)
10     Silvertown Wharf POINT (540440 179720)
```
## Distributing emissions
The `small_grid_result` was grouped by `large_grid_id` to calculate the total number of GPS points in the parent grids. Then the count of GPS points in each 20m by 20m grid, was divided by the total of GPS points within the larger grid (1km by 1km) for that area, to give a weighting for each small grid to draw down the emissions. The grid cells containing berths were calculated in a similar manner but indenpendantly i.e. only cells that contained berths were divided by the `berth_count`. This created the `contribution` column.

```r
Simple feature collection with 126714 features and 8 fields
geometry type:  POLYGON
dimension:      XY
bbox:           xmin: 523860 ymin: 174420 xmax: 558000 ymax: 186900
epsg (SRID):    27700
proj4string:    +proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +towgs84=446.448,-125.157,542.06,0.15,0.247,0.842,-20.489 +units=m +no_defs
First 10 features:
   large_grid_id small_grid_id group count berth_name sailing_count berth_count contribution                       geometry
1           9717          2928     1     2       <NA>             9          NA  0.222222222 POLYGON ((533280 181060, 53...
2           9717          2981     1     3       <NA>             9          NA  0.333333333 POLYGON ((533300 181080, 53...
3           9717          3085     1     2       <NA>             9          NA  0.222222222 POLYGON ((533300 181120, 53...
4           9717          3397     1     1       <NA>             9          NA  0.111111111 POLYGON ((533300 181240, 53...
5           9717          3642     1     1       <NA>             9          NA  0.111111111 POLYGON ((533000 181360, 53...
6           9728          5496     1     2       <NA>           719          NA  0.002781641 POLYGON ((544700 181000, 54...
7           9728          5497     1     5       <NA>           719          NA  0.006954103 POLYGON ((544720 181000, 54...
8           9728          5498     1     2       <NA>           719          NA  0.002781641 POLYGON ((544740 181000, 54...
9           9728          5499     1     5       <NA>           719          NA  0.006954103 POLYGON ((544760 181000, 54...
10          9728          5500     1     4       <NA>           719          NA  0.005563282 POLYGON ((544780 181000, 54...
```

The small_grid was now duplicated 3 times, a pollutant column added to each and populated (PM2.5, NOx and PM), and then joined back together again. It was then joined to the emissions by `pollutant`, `group` and `unique_geom_id`. Subsequently the `contribution` was multiplied by the emission for that large grid square, and stored as `emissions`.

## Results

![Nox group 1 emissions result](https://github.com/JimShady/laei_river_data/blob/master/maps/nox_group_1_result_emissions.png)

![Nox group 2 emissions result](https://github.com/JimShady/laei_river_data/blob/master/maps/nox_group_2_result_emissions.png)

![PM2.5 group 2 emissions result](https://github.com/JimShady/laei_river_data/blob/master/maps/pm25_group_2_result_emissions.png)

## Issues

### 1km by 1km grids with emissions but no GPS points

There are 1km by 1km emission grid areas from the PLA, with emissions for sailing/berth, where there is no GPS data.

```r

small_grid_result %>% 
      as_tibble() %>% 
      group_by(large_grid_id, pollutant, group) %>% 
      summarise(gps_count = sum(count, na.rm=T)) %>% 
      left_join(grid_emissions, ., by = c("large_grid_id" = "large_grid_id",
                                          "group"="group",
                                          "pollutant"="pollutant")) %>% 
      filter(gps_count == 0 & (sailing > 0 | berth > 0))

# A tibble: 62 x 6
   pollutant group large_grid_id sailing berth gps_count
   <chr>     <dbl>         <dbl>   <dbl> <dbl>     <int>
 1 NOx           1          9559   0.17   0            0
 2 NOx           1          9893   0.02   0            0
 3 NOx           1         10081   0.01   0            0
 4 NOx           2          9383   0.16   0            0
 5 NOx           2          9384   0.900  0            0
 6 NOx           2          9556   1.55   0            0
 7 NOx           2          9557   5.76   0.48         0
 8 NOx           2          9559   5.17  12.9          0
 9 NOx           2          9560   0.64   0            0
10 NOx           2          9717   0.01   0            0
# ... with 52 more rows
```
However the emissions in these `large_grid_squares` are a very small proportion of the total emissions (shown below) so we have decided not to investigate this issue further.

|Pollutant | Sailing | Berth  |
|:--------:|:-------:|:------:|
| NOx      | 0.003%  | 0.006% |
| PM       | 0.002%  | 0.006% |
| PM2.5    | 0.002%  | 0.006% |
-------------------------------

### Artifacts

Due to the way that the emissions were calculated on a grid, there are some artefacts when visualising the data, such as shown below. These have not been resolved (as there is no easy way to do so). It is a limitation of the underlying data/method before our work.

![Map of artifacts]()
