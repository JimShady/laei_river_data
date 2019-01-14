# Method summary

## Emissions
PLA 2016 emissions covering London are imported as a [CSV](https://github.com/JimShady/laei_river_data/blob/master/emissions/inventory_export_2016.csv). These contain for each pollutant, ship type and cellid (LAEI exact cut) the estimated shipping emissions in kg per annum for that area. There are 12 ship types in the inventory, however these are grouped by [vessel class](https://github.com/JimShady/laei_river_data/blob/master/docs/vessel_classifications.csv) (also provided by PLA) to 4 types. Henceforth known as `Group 1`, `Group 2`, `Group 3` and `Group 4`. This data is now joined to a geopackage of the LAEI grid exact cuts using the `cellid` identifier. A map of NO2 emissions over this domain is shown below.

![Map of NO2 emissions](https://github.com/JimShady/laei_river_data/blob/master/maps/large_grid_sailing.png)

## The 20m grid
A 20m x 20m polygon grid (`small_grid`) covering the extent of the emission grid was now created. This was then intersected with a unique geographical representation of the emissions grid i.e. just one cell for each area, rather than twelve cslls (3 pollutants x 4 groups). A `unique_geom_id` column was added to the `small_grid`, to enable linking of the 'small_grid' back to the original emissions.

![Map of small grid](https://github.com/JimShady/laei_river_data/blob/master/maps/small_grid.png)



