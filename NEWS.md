# neighbourhoodstudy 0.9.5

* In function `query_osm_api()` make `columns_to_select` a parameter.

# neighbourhoodstudy 0.9.4

* Bugfix in function `query_osm_api()` when using parameter `manual_tags`.

# neighbourhoodstudy 0.9.3

* Update function `query_osm_api()` to add optional parameter `manual_tags` for more flexible searching.


# neighbourhoodstudy 0.9.2

* Fix column name in get_avg_dist_to_closest_n()

# neighbourhoodstudy 0.9.1

* Bugfix in query_osm_api for multiple shops

# neighbourhoodstudy 0.9.0

* Breaking change, renamed & refactored get_avg_dist_to_closest_three() to get_avg_dist_to_closest_n().

# neighbourhoodstudy 0.8.0

* Four new functions to calculate common ONS values.

# neighbourhoodstudy 0.7.0

* Ensured sli_das_gen3_mape values are all characters.

# neighbourhoodstudy 0.6.0

* Added query_osm_api() function
* Removed ottawa_phhs_shp from ISED data in preference of ottawa_phhs, custom set
* Added sli_das_gen3_mape, single-link indicator from 2021 DAs to Gen3 hoods using `sliopt` package and mean average percentage error.

# neighbourhoodstudy 0.5.0

* Added a `NEWS.md` file to track changes to the package.
* Added custom Ottawa pseudohouseholds
* Added SLI for DBs-gen3 neighbourhoods based on max overlaps

# neighbourhoodstudy 0.4.0

* New 2021 da shape data
* Add years to statscan variable names
