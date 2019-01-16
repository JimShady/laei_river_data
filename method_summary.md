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

The `vessel_classifications` are joined to the `inventory_export_2016.csv` by `ship_type`. However there are three `ship_type`'s in the emissions that do not exactly match with the `vessel_classifications` file. These are edited to force them to link, as below.

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

This data is now joined to a geopackage of the LAEI grid exact cuts using the `cellid` identifier. A map of NOx emission for sailing and berth and view of the data is shown below.

```r
Simple feature collection with 1590 features and 5 fields
geometry type:  MULTIPOLYGON
dimension:      XY
bbox:           xmin: 501000 ymin: 152000 xmax: 586000 ymax: 204000
epsg (SRID):    27700
proj4string:    +proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +towgs84=446.448,-125.157,542.06,0.15,0.247,0.842,-20.489 +units=m +no_defs
# A tibble: 1,590 x 6
   cellid pollutant group  sailing    berth                                                                            geom
    <dbl> <chr>     <dbl>    <dbl>    <dbl>                                                              <MULTIPOLYGON [m]>
 1    231 NOx           1    54.6      0    (((555000 178000, 556000 178000, 556000 177000, 555000 177000, 555000 178000)))
 2    231 NOx           2  6778.       2.09 (((555000 178000, 556000 178000, 556000 177000, 555000 177000, 555000 178000)))
 3    231 NOx           3  1429.       0    (((555000 178000, 556000 178000, 556000 177000, 555000 177000, 555000 178000)))
 4    231 NOx           4  3970.    4567.   (((555000 178000, 556000 178000, 556000 177000, 555000 177000, 555000 178000)))
 5    232 NOx           1     3.35     0    (((556000 178000, 557000 178000, 557000 177000, 556000 177000, 556000 178000)))
 6    232 NOx           2   521.       1.54 (((556000 178000, 557000 178000, 557000 177000, 556000 177000, 556000 178000)))
 7    232 NOx           3    95.7      0    (((556000 178000, 557000 178000, 557000 177000, 556000 177000, 556000 178000)))
 8    232 NOx           4 10367.   29460.   (((556000 178000, 557000 178000, 557000 177000, 556000 177000, 556000 178000)))
 9    234 NOx           1     2.28     0    (((555000 177000, 556000 177000, 556000 176000, 555000 176000, 555000 177000)))
10    234 NOx           2   332.       0    (((555000 177000, 556000 177000, 556000 176000, 555000 176000, 555000 177000)))
```
![NOx berth group 1](https://github.com/JimShady/laei_river_data/blob/master/maps/large_grid_berth_group_one_nox.png)

![NOx sailing group 1](https://github.com/JimShady/laei_river_data/blob/master/maps/large_grid_sailing_group_one_nox.png)

## The 20m grid
A 20m x 20m polygon grid (`small_grid`) covering the extent of the emission grid was now created. This was then intersected and clipped with a unique geographical representation of the emissions grid i.e. just one cell for each emission area, rather than twelve cells (3 pollutants x 4 groups). The link between the `small_grid` and the emissions is by `cellid`. Some of the data, and a section of the grid are shown below.

```r
Simple feature collection with 305920 features and 2 fields
geometry type:  GEOMETRY
dimension:      XY
bbox:           xmin: 523000 ymin: 174000 xmax: 558000 ymax: 187000
epsg (SRID):    27700
proj4string:    +proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +towgs84=446.448,-125.157,542.06,0.15,0.247,0.842,-20.489 +units=m +no_defs
First 10 features:
   cellid                       geometry small_grid_id
1     231 POLYGON ((555000 177020, 55...             1
2     231 POLYGON ((555000 177000, 55...             2
3     231 POLYGON ((555020 177000, 55...             3
4     231 POLYGON ((555040 177000, 55...             4
5     231 POLYGON ((555060 177000, 55...             5
6     231 POLYGON ((555080 177000, 55...             6
7     231 POLYGON ((555100 177000, 55...             7
8     231 POLYGON ((555120 177000, 55...             8
9     231 POLYGON ((555140 177000, 55...             9
10    231 POLYGON ((555160 177000, 55...            10
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
On 1 January 2016 there were 1,368,454 GPS points in the dataset, 336,967 (25%) of which had no category. The remaining categories and counts are as below. 

```r
   BBU    BCE    BWC    DTD    DTS    GGC    GPC    OFY    OSU    OYT    PRR    RSR    TCO    TEO    TPD    URR    XFF    XTG 
112277  21895  97107  43833   3207  30064  17034 116524  43235  16190  26679  53785  82291  17810   4055  44135  42119 259246
```
## Counting GPS points
The AIS data was imported in turn, and spatially joined to the `small_grid`. The result being that each `small_grid` contained the count of the total number of GPS points, per `group`, that had been recorded in that grid square. The map and data below show the annual count of GPS points within each grid square.

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

![Map of small grid GPS counts in cell 231](https://github.com/JimShady/laei_river_data/blob/master/maps/small_grid_gps_count_cell231.png)

## Berths
The PLA 2016 emissions are split between `sailing` and `berth`. The berth emissions will be distributed to the berths that are within each `cellid`, weighted by the number of GPS points within the `small_grid` cell of the berth. A shapefile of berths was therefore imported, and joined to the small grid, adding an extra column to identify if that small_grid cell held a berth or not. 

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
   cellid small_grid_id group count berth_name sailing_count berth_count contribution                       geometry
1     231            40     1     3       <NA>          8271           2 0.0003627131 POLYGON ((555760 177000, 55...
2     231            41     1     1       <NA>          8271           2 0.0001209044 POLYGON ((555780 177000, 55...
3     231            44     1     2       <NA>          8271           2 0.0002418087 POLYGON ((555840 177000, 55...
4     231            46     1     7       <NA>          8271           2 0.0008463306 POLYGON ((555880 177000, 55...
5     231            47     1    12       <NA>          8271           2 0.0014508524 POLYGON ((555900 177000, 55...
6     231            48     1     6       <NA>          8271           2 0.0007254262 POLYGON ((555920 177000, 55...
7     231            49     1    11       <NA>          8271           2 0.0013299480 POLYGON ((555940 177000, 55...
8     231            50     1     4       <NA>          8271           2 0.0004836175 POLYGON ((555960 177000, 55...
9     231            51     1    10       <NA>          8271           2 0.0012090436 POLYGON ((555980 177000, 55...
10    231            88     1     1       <NA>          8271           2 0.0001209044 POLYGON ((555700 177020, 55...
```

The small_grid was now duplicated 3 times, a pollutant column added to each and populated (PM2.5, NOx and PM), and then joined back together again. It was then joined to the emissions by `pollutant`, `group` and `unique_geom_id`. Subsequently the `contribution` was multiplied by the emission for that large grid square, and stored as `emissions`.

## Results

### Group 1 NOx
![Map of PLA berths](https://github.com/JimShady/laei_river_data/blob/master/maps/emissions_nox_group_1.png)

### Group 2 NOx
![Map of PLA berths](https://github.com/JimShady/laei_river_data/blob/master/maps/emissions_nox_group_2.png)

### Group 3 NOx
![Map of PLA berths](https://github.com/JimShady/laei_river_data/blob/master/maps/emissions_nox_group_3.png)

### Group 4 NOx
![Map of PLA berths](https://github.com/JimShady/laei_river_data/blob/master/maps/emissions_nox_group_4.png)

## Issues

### 1km by 1km grids with emissions but no GPS points

There are 1km by 1km emission grid areas from the PLA, with emissions for sailing/berth, where there is no GPS data.

```r

small_grid_result %>% 
      as_tibble() %>% 
      group_by(cellid, group) %>% 
      summarise(gps_count = sum(count, na.rm=T)) %>% 
      left_join(grid_emissions, ., by = c("cellid" = "cellid", "group"="group")) %>% 
      filter(gps_count == 0 & (sailing > 0 | berth > 0))

Simple feature collection with 96 features and 7 fields
geometry type:  MULTIPOLYGON
dimension:      XY
bbox:           xmin: 523000 ymin: 174000 xmax: 554000 ymax: 184694.5
epsg (SRID):    27700
proj4string:    +proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +towgs84=446.448,-125.157,542.06,0.15,0.247,0.842,-20.489 +units=m +no_defs
# A tibble: 96 x 8
   cellid pollutant group sailing berth    id gps_count                                                                                    geom
    <dbl> <chr>     <dbl>   <dbl> <dbl> <int>     <int>                                                                      <MULTIPOLYGON [m]>
 1    827 NOx           2    0.48  0       26         0 (((545425.6 182000, 545425.8 182005.6, 545427.6 182023.9, 545430.7 182042.3, 545442....
 2    828 NOx           2    5.28  0.48    28         0 (((545425.6 182000, 545000 182000, 545000 182909, 545000.1 182909, 545023.9 182910.3...
 3    829 NOx           1    0.17  0       31         0         (((547000 183000, 548000 183000, 548000 182000, 547000 182000, 547000 183000)))
 4    829 NOx           2    5.17 12.9     32         0         (((547000 183000, 548000 183000, 548000 182000, 547000 182000, 547000 183000)))
 5    898 NOx           2    1.08  0       89         0 (((536000 178627.7, 536000 179000, 536805.4 179000, 536735.5 178975.1, 536732.1 1789...
 6    906 NOx           2    0.04  0      100         0         (((550000 179000, 551000 179000, 551000 178000, 550000 178000, 550000 179000)))
 7    949 NOx           2    0.05  0      114         0 (((553615.3 176000, 554000 176000, 554000 175000, 553037.5 175000, 553035.9 175007.1...
 8    950 NOx           2    0.37  0.01   115         0 (((553000 176000, 553615.3 176000, 553612.6 175998.3, 553580.8 175989.5, 553571.5 17...
 9   1505 NOx           2    0.44  0      124         0 (((544000 183000, 544473.6 183000, 544486.1 182994.7, 544526.4 182979.5, 544568.6 18...
10   1506 NOx           2    1.11  0      125         0 (((544473.6 183000, 545000 183000, 545000 182909, 544991.2 182912.8, 544975.5 182912...
# ... with 86 more rows
```

### 1km by 1km grids with GPS points(>20) but no emissions

Very small issue, only two grids with small number of GPS points (drift?), suggest ignore, but shown for completeness.

```r
small_grid_result %>% 
      as_tibble() %>% 
      group_by(cellid, group) %>% 
      summarise(gps_count = sum(count, na.rm=T)) %>% 
      left_join(grid_emissions, ., by = c("cellid" = "cellid", "group"="group")) %>% 
      filter(gps_count > 20 & sailing == 0 & berth== 0)

Simple feature collection with 2 features and 7 fields
geometry type:  MULTIPOLYGON
dimension:      XY
bbox:           xmin: 528000 ymin: 177000 xmax: 530000 ymax: 178000
epsg (SRID):    27700
proj4string:    +proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +towgs84=446.448,-125.157,542.06,0.15,0.247,0.842,-20.489 +units=m +no_defs
# A tibble: 2 x 8
  cellid pollutant group sailing berth    id gps_count                                                                                    geom
   <dbl> <chr>     <dbl>   <dbl> <dbl> <int>     <int>                                                                      <MULTIPOLYGON [m]>
1   2276 NOx           4       0     0   338        82 (((528000 177659.2, 528000 178000, 528507.6 178000, 528522.2 177986.4, 528534.5 1779...
2   2947 NOx           4       0     0   435       525 (((529000 177792.7, 529007.3 177792.2, 529013.6 177790.8, 529044 177783.4, 529071.4 ...
```
### Artifacts

[Map of artifacts](https://github.com/JimShady/laei_river_data/blob/master/maps/river_artifact.png)
