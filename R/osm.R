# for clean R CMD CHECK
name <- NULL


#' Query the OpenStreetMaps (OSM) Overpass API for Amenities and Shops
#'
#' Retrieve data from OSM for any number of amenity or shop key values and
#' return a tidy list of point-wise results. Polygons are converted to centroids.
#'
#' @param bounding_box_shp An sf object that will be used to create a square bounding box for the search.
#' @param amenities Optional. A character vector of amenity key values to search for.
#' @param manual_tags Optional. A character vector of manual tags to search for. Each tag
#'                    must be its own element in the vector and values must be surrounded
#'                    by double quotes. For example, c('"drink:wine"="yes"', '"drink:beer"="yes"', '"amenity"="bank"')
#' @param shops Optional. A character vector of shop key values to search for.
#' @param process Boolean, default TRUE. Processes data to return a tidy result. If FALSE, returns raw Overpass API response.
#' @param drop_unnamed_elements Boolean, default TRUE. Removes elements with no name that seem to be returned in error when searching e.g. for cafes.
#' @param columns_to_select Character vector, optional. If provided, it will select dplyr::any_of() the provided column names. If set to NA it will return all columns.
#'
#' @return A tibble of OSM elements with point locations.
#' @export
query_osm_api <- function(bounding_box_shp, amenities= "", shops = "", manual_tags = "", process = TRUE, drop_unnamed_elements = TRUE,
                          columns_to_select = c("osm_id", "name", "shop", "amenity", "brand", "addr.street", "addr.housenumber", "addr.city", "addr.postcode")) {


  if (all(shops == "") & all(amenities == "") & all(manual_tags == "")) stop ("Must provide character vector of shop or amenity key-values.")

  osm_query <- osmdata::opq(bbox = sf::st_bbox(bounding_box_shp), timeout = 10000)

  if (!all(shops == "")){
    shops_query <- paste0("\"shop\"=\"", shops, "\"" )
  }  else {
    shops_query <- NULL
  }

  if (!all(amenities == "")) {
    amenities_query <- paste0("\"amenity\"=\"", amenities, "\"" )
  } else {
    amenities_query <- NULL
  }

  if (!all(manual_tags == "")){
    manual_query <- manual_tags
  } else {
    manual_query <- NULL
  }

  osm_query <- osmdata::add_osm_features(osm_query, features = c(shops_query, amenities_query, manual_query))

  overpass_data <- osmdata::osmdata_sf(osm_query, quiet = FALSE)


  # if we are not processing the data, return raw api response
  if (process == FALSE) {
    result <- overpass_data
  }

  # if we are processing data, do that here
  if (process == TRUE) {
    # extract the point and polygons. some stores shop up as only points, some
    # as only polygons, so we need both
    osm_pts <- overpass_data$osm_points
    osm_polys <- overpass_data$osm_polygons


    osm_pts <- osm_pts |>
      dplyr::as_tibble() |>
      sf::st_as_sf() #|> dplyr::select(dplyr::any_of(columns_to_select))

    osm_poly_centroids <- osm_polys |>
      dplyr::as_tibble() |>
      sf::st_as_sf()

    sf::st_agr(osm_poly_centroids) <- "constant"

    osm_poly_centroids <- osm_poly_centroids |>
      sf::st_centroid()


    # combine points and polygons
    # create a new column called "type" that combines shop and amenity into one value
    result <- dplyr::bind_rows(osm_pts, osm_poly_centroids)

    if (!all(is.na(columns_to_select))) {
      result <- dplyr::select(result, dplyr::any_of(columns_to_select))
    }

    if (drop_unnamed_elements){
      result <- dplyr::filter(result, !is.na(name))
    }
  }

  return (result)
}
