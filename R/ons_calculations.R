DAUID <- DBUID <- ONS_ID <- SF_TotalPop <- covered <- dbpop2021 <- dist_closest_3 <- distance <- num_per_1000_res_plus_buffer <- num_region_plus_buffer <- time <- NULL

`:=` <- rlang::`:=`

#' Count points in regions plus a buffer
#'
#' @param region_shp Sf object with polygonal shapes, one row per region, with at
#' least one column providing unique region identifiers.
#' @param point_data Sf object with point data to aggregate to regions.
#' @param region_id_col Character, column name in `region_shp` containing unique
#' region identifiers.
#' @param crs The CRS to convert regions and points to. Defaults to 32189
#' (NAD83 / MTM zone 9) for Ottawa, Ontario.
#' @param buffer_m Buffer in meters to apply to regions.
#'
#' @return A tibble with one row per region and the number of points within each.
#' @export
get_number_per_region_plus_buffer <- function(region_shp, point_data, region_id_col = "ONS_ID", crs = 32189, buffer_m = 50) {

  region_shp <- sf::st_transform(region_shp, crs=32189) |>
    sf::st_buffer(buffer_m) |>
    dplyr::select(-dplyr::any_of(c("join_field", "SHAPE_Leng", "SHAPE_Area", "ONS_Name", "ONS_Region")))

  point_data <- sf::st_transform(point_data, crs=32189)

  raw_counts <- sf::st_join(point_data, region_shp) |>
    sf::st_drop_geometry() |>
    dplyr::group_by(!!rlang::sym(region_id_col)) |>
    dplyr::summarise(num_region_plus_buffer = dplyr::n(), .groups = "drop")

  # create overall measure too for id_col values = 0
  # find points within the union of the buffered areas, count rows
  raw_count_overall <- sf::st_filter(point_data, sf::st_as_sf(sf::st_union(region_shp))) |>
    sf::st_drop_geometry() |>
    dplyr::summarise(num_region_plus_buffer = dplyr::n()) |>
    dplyr::mutate({{region_id_col}} := "0", .before = 1 )

  # get hoodwise counts
  result <- dplyr::full_join(sf::st_drop_geometry(region_shp), raw_counts, by = region_id_col ) |>
    dplyr::mutate(num_region_plus_buffer = dplyr::if_else(is.na(num_region_plus_buffer), 0, num_region_plus_buffer)) |>
    tidyr::drop_na(!!rlang::sym(region_id_col)) |>
    dplyr::arrange(!!rlang::sym(region_id_col))

  # combine overall with hoodwise
  result <- dplyr::bind_rows(raw_count_overall, result)

  # if no buffer, then do not name the column "plus_buffer"
  if (buffer_m == 0) {
    result <- dplyr::rename(result, num_region = num_region_plus_buffer)
  }

  return(result)
}

#' Count points per 1000 residents in regions plus a buffer
#'
#' @param region_shp Sf object with polygonal shapes, one row per region, with at
#' least one column providing unique region identifiers.
#' @param point_data Sf object with point data to aggregate to regions.
#' @param pop_data Data frame giving regional population data, including at least
#' one column with unique region identifiers and one column with population data.
#' @param region_id_col Character, column name in `region_shp` containing unique
#' region identifiers.
#' @param pop_col character, column name in `pop_data` containing populations.
#' @param crs The CRS to convert regions and points to. Defaults to 32189
#' (NAD83 / MTM zone 9) for Ottawa, Ontario.
#' @param buffer_m Buffer in meters to apply to regions.
#'
#' @return A tibble with one row per region and the number of points within each.
#' @export
get_number_per_region_per_1000_residents_plus_buffer <- function(region_shp, point_data, pop_data, region_id_col = "ONS_ID", pop_col = "SF_TotalPop", crs = 32189, buffer_m = 50) {

  # add ottawa-wide population value to pop_data if we're taking
  # input from package `neighbourhoodstudy`
  #region_shp <- ons_gen3_shp
  #point_data <- foodspace_grocery
  #pop_data <- neighbourhoodstudy::ons_gen3_pop2021

  if ( region_id_col == "ONS_ID" && ! "0" %in% pop_data$ONS_ID) {
    pop_ott <- sum(pop_data[,pop_col, drop = TRUE])
    pop_data <- dplyr::add_row(pop_data, ONS_ID = "0", ONS_Name = "OTTAWA",  {{pop_col}} := pop_ott, .before = 1)
  }


  # first we get the numbers per region, including ottawa-wide
  num_per_region <- get_number_per_region_plus_buffer(region_shp, point_data, region_id_col, crs, buffer_m)

  # then divide by population
  result <- dplyr::left_join(num_per_region, pop_data, by = region_id_col) |>
    dplyr::mutate(num_per_1000_res_plus_buffer = num_region_plus_buffer / SF_TotalPop * 1000) |>
    dplyr::select(dplyr::all_of(region_id_col), num_per_1000_res_plus_buffer)

  # methodology choice: give NA for any division by zero, could arguably give 0 instead
  result <- result |>
    #dplyr::arrange(dplyr::desc(num_per_1000)) |> View()
    tidyr::drop_na(!!rlang::sym(region_id_col)) |>
    dplyr::mutate(num_per_1000_res_plus_buffer = dplyr::if_else(is.na(num_per_1000_res_plus_buffer) | is.infinite(num_per_1000_res_plus_buffer) | is.nan(num_per_1000_res_plus_buffer), NA, num_per_1000_res_plus_buffer))

  return(result)
}




#' Use a pre-computed origin-destination table to get ONS Neighbourhood-level average distances from DB centroids to closest n features
#'
#' @param od_table tibble output from `valhallr::od_table()` with columns `distance` and `time`
#' @param from_id_col Character, name of column with unique origin identifiers. Default "DBUID".
#' @param to_id_col Character, name of column with unique destination identifiers.
#' @param froms_to_ons_sli Single-link indicator (SLI) from origins to ONS neighbourhoods. Consider using `neighbourhoodstudy::sli_das_gen3_mape`.
#' @param dbpops Tibble, in the format of (or consider using) `neighbourhoodstudy::ottawa_dbs_pop2021`.
#' @param n Integer, # of closts features to consider.
#'
#' @return Tibble with average distance to n closest features at ONS neighbourhood and Ottawa levels.
#' @export
get_avg_dist_to_closest_n <- function(od_table, from_id_col = "DBUID", to_id_col, froms_to_ons_sli, dbpops, n) {

  # take the od_table, get top n closest by distance for each origin,
  # average them, get populations for DBUIDs, convert DBUIDs to DAUIDs, use
  # single-link indicator to map DAs to ONS hoods, pop-weight avg distance from
  # DAs up to gen3 hoods
  # first get db-level results, so we can do hoods and citywide
  result_dbs <-  tidyr::drop_na(od_table) |>
    dplyr::group_by(!!rlang::sym(from_id_col)) |>
    dplyr::arrange(distance) |>
    dplyr::slice_head(n=n) |>
    dplyr::summarise(dist_closest_3 = mean(distance, na.rm = TRUE)) |>
    dplyr::left_join(dbpops, by = "DBUID") |>
    dplyr::mutate(DAUID = substr(DBUID, 1, 8))

  # hood results
  result_hoods <- result_dbs |>
    dplyr::left_join(froms_to_ons_sli, by = "DAUID") |>
    dplyr::select(DAUID, dist_closest_3, dbpop2021, ONS_ID) |>
    dplyr::group_by(ONS_ID) |>
    dplyr::summarise(dist_closest_3_popwt = sum((dist_closest_3 * dbpop2021) / sum(dbpop2021) ))

  # citywide
  result_ott <- result_dbs |>
    dplyr::summarise(dist_closest_3_popwt = sum((dist_closest_3 * dbpop2021) / sum(dbpop2021) )) |>
    dplyr::mutate(ONS_ID = "0", .before = 1)

  result <- dplyr::bind_rows(result_ott, result_hoods)

  return(result)
}


# take the od_table, find out if DBs have ANY trips under 15 minutes,
# add DB pops, link DBs to DAs, link DAs to hoods using sli, use db pops and
# whether they're covered or not to estimate % of hood pop within 15 minutes

#' Use precomputed distance tables to get the percentage of residents within 15-minute walk of features
#'
#' @param od_table tibble output from `valhallr::od_table()` with columns `distance` and `time`
#' @param from_id_col Character, name of column with unique origin identifiers. Default "DBUID".
#' @param to_id_col Character, name of column with unique destination identifiers.
#' @param froms_to_ons_sli Single-link indicator (SLI) from origins to ONS neighbourhoods. Consider using `neighbourhoodstudy::sli_das_gen3_mape`.
#' @param dbpops Tibble, in the format of (or consider using) `neighbourhoodstudy::ottawa_dbs_pop2021`.
#'
#' @return Tibble with percent of residents within 15-minute walk at ONS neighbourhood and Ottawa levels.
#' @export
get_pct_within_15_mins <- function(od_table, from_id_col = "DBUID", to_id_col, froms_to_ons_sli, dbpops) {

  # take the od_table, find out if DBs have ANY trips under 15 minutes,
  # add DB pops, link DBs to DAs, link DAs to hoods using sli, use db pops and
  # whether they're covered or not to estimate % of hood pop within 15 minutes
  result_db <-  tidyr::drop_na(od_table) |>
    dplyr::group_by(!!rlang::sym(from_id_col)) |>
    dplyr::summarise(covered = any (time < 15 * 60)) |>
    dplyr::left_join(dbpops, by = "DBUID") |>
    dplyr::mutate(DAUID = substr(DBUID, 1, 8))

  result_hood <- result_db |>
    dplyr::left_join(froms_to_ons_sli, by = "DAUID") |>
    dplyr::select(DAUID, covered, dbpop2021, ONS_ID) |>
    dplyr::group_by(ONS_ID) |>
    dplyr::summarise(pct_within_15_mins = sum((covered * dbpop2021) / sum(dbpop2021) ))

  result_ott <- result_db |>
    dplyr::summarise(pct_within_15_mins = sum((covered * dbpop2021) / sum(dbpop2021) ) )|>
    dplyr::mutate(ONS_ID = "0", .before = 1)

  result <- dplyr::bind_rows(result_ott, result_hood)

  return(result)
}

