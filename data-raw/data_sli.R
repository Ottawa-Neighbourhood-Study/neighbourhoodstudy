# Create single-link indicator from 2021 StatsCan DBs to ONS Gen3 neighbourhoods
library(sf)

dbs <- neighbourhoodstudy::ottawa_dbs_shp2021 |> sf::st_make_valid()
ons <- neighbourhoodstudy::ons_gen3_shp |>
  dplyr::filter(ONS_Region == "OTTAWA") |>
  sf::st_make_valid()

tictoc::tic()
z <- sf::st_intersection(dbs, ons)
sli_dbs_gen3_maxoverlap <- z |>
  dplyr::mutate(area = as.numeric(sf::st_area(geometry))) |>
  dplyr::group_by(DBUID) |>
  dplyr::arrange(DBUID) |>
  dplyr::mutate(n = dplyr::n()) |>
  dplyr::arrange(dplyr::desc(n), DBUID, dplyr::desc(area)) |>
  #dplyr::arrange(DBUID, dplyr::desc( dplyr::n()))
  #dplyr::arrange(dplyr::desc(area)) |>
  dplyr::slice_head(n=1) |>
  dplyr::select(-area, -n)
tictoc::toc()
sli_dbs_gen3_maxoverlap <- dplyr::select(sli_dbs_gen3_maxoverlap, DBUID, ONS_ID) |> sf::st_set_geometry(NULL)
usethis::use_data(sli_dbs_gen3_maxoverlap, overwrite = TRUE)
######
#
# ottawa_dbs_shp2021 <- neighbourhoodstudy::ottawa_dbs_shp2021 |>
#   dplyr::left_join(neighbourhoodstudy::ottawa_dbs_pop2021, by = dplyr::join_by(DBUID)) |>
#   sf::st_make_valid()
#
# ons_gen3_shp <- neighbourhoodstudy::ons_gen3_shp |>
#   dplyr::filter(ONS_Region == "OTTAWA") |>
#   dplyr::left_join(neighbourhoodstudy::ons_gen3_pop2021, by = dplyr::join_by(ONS_ID)) |>
#   sf::st_make_valid()
#
# ons_db_gen3_sli <- sliopt::greedy_sli_search(from_shp = ottawa_dbs_shp2021, from_idcol = "DBUID", from_valuecol = "dbpop2021",
#                           to_shp = ons_gen3_shp, to_idcol = "ONS_ID", to_valuecol = "SF_TotalPop",
#                           optimize_for = "mape", tolerance = 0.1, iterations = 3, shuffle_inputs = TRUE)


