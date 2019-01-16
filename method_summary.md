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

![Map of small grid GPS counts in ecll 231](https://github.com/JimShady/laei_river_data/blob/master/maps/small_grid_gps_count_cell231.png)

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

## Problems

### 1km by 1km grids with emissions but no GPS points

There are 1km by 1km emission grid areas from the PLA, with emissions for sailing/berth, where there is no GPS data. For example 
`unique_geom_id` area 11 has the below emissions.

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

On further inspection it seems that there might be some missclassifcation happening, as in this case there are only emissions for groups 2 and 3. But only GPS for groups 3 and 4. Have some of the GPS points been classified as 3 or 4, when they should have been classified as 2?

```r
Simple feature collection with 6 features and 6 fields
geometry type:  POLYGON
dimension:      XY
bbox:           xmin: 545000 ymin: 182000 xmax: 546000 ymax: 183000
epsg (SRID):    27700
proj4string:    +proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +towgs84=446.448,-125.157,542.06,0.15,0.247,0.842,-20.489 +units=m +no_defs
  pollutant group     sailing       berth id unique_geom_id                           geom
1       NOx     2 0.480000000 0.000000000 76             11 POLYGON ((545425.6 182000, ...
2       NOx     3 0.260000000 0.180000000 77             11 POLYGON ((545425.6 182000, ...
3        PM     2 0.014647966 0.000000000 78             11 POLYGON ((545425.6 182000, ...
4        PM     3 0.005557789 0.004036391 79             11 POLYGON ((545425.6 182000, ...
5     PM2.5     2 0.013915568 0.000000000 80             11 POLYGON ((545425.6 182000, ...
6     PM2.5     3 0.005279900 0.003834572 81             11 POLYGON ((545425.6 182000, ...
```

### 1km by 1km grids with GPS points(>20) but no emissions

I guess this doesn't matter, but it's a bit of a concern.
```r
Simple feature collection with 1728 features and 13 fields
geometry type:  POLYGON
dimension:      XY
bbox:           xmin: 524080 ymin: 175760 xmax: 545300 ymax: 182660
epsg (SRID):    27700
proj4string:    +proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +towgs84=446.448,-125.157,542.06,0.15,0.247,0.842,-20.489 +units=m +no_defs
First 10 features:
   unique_geom_id small_grid_id group gps_count berth_name sailing_count berth_count contribution pollutant sailing berth id emissions                       geometry
1             118        199136     1       912       <NA>        100134          NA 0.0091077956       NOx      NA    NA NA        NA POLYGON ((528003.7 177660, ...
2             118        199137     1       536       <NA>        100134          NA 0.0053528272       NOx      NA    NA NA        NA POLYGON ((528020 177640, 52...
3             118        199138     1       218       <NA>        100134          NA 0.0021770827       NOx      NA    NA NA        NA POLYGON ((528040 177640, 52...
4             118        199139     1        67       <NA>        100134          NA 0.0006691034       NOx      NA    NA NA        NA POLYGON ((528060 177640, 52...
5             118        199186     1       158       <NA>        100134          NA 0.0015778856       NOx      NA    NA NA        NA POLYGON ((528020 177664, 52...
6             118        199187     1       556       <NA>        100134          NA 0.0055525596       NOx      NA    NA NA        NA POLYGON ((528040 177668.9, ...
7             118        199188     1       894       <NA>        100134          NA 0.0089280364       NOx      NA    NA NA        NA POLYGON ((528060 177673.8, ...
8             118        199189     1      1002       <NA>        100134          NA 0.0100065912       NOx      NA    NA NA        NA POLYGON ((528080 177678.7, ...
9             118        199190     1       895       <NA>        100134          NA 0.0089380230       NOx      NA    NA NA        NA POLYGON ((528085.2 177680, ...
10            118        199191     1       476       <NA>        100134          NA 0.0047536301       NOx      NA    NA NA        NA POLYGON ((528100 177660, 52...
```


### Artifacts

Grid exact cuts have led to some strange results. For example cellid 2238 v 2239, NOX, . They are the mirror half of each other on the river. But not has high emissions, and one low. Maybe need to investigate aggregating the exact cuts back up to full grids and then doing the process again. Though this is difficult as they don't exactly line up.
