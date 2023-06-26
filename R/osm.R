


#' Query the OpenStreetMaps (OSM) Overpass API for Amenities and Shops
#'
#' Retrieve data from OSM for any number of amenity or shop key values and
#' return a tidy list of point-wise results. Polygons are converted to centroids.
#'
#' @param bounding_box_shp An sf object that will be used to create a square bounding box for the search.
#' @param amenities Optional. A character vector of amenity key values to search for.
#' @param shops Optional. A character vector of shop key values to search for.
#' @param process Boolean, default TRUE. Processes data to return a tidy result. If FALSE, returns raw Overpass API response.
#' @param drop_unnamed_elements Boolean, default TRUE. Removes elements with no name that seem to be returned in error when searching e.g. for cafes.
#'
#' @return A tibble of OSM elements with point locations.
#' @export
query_osm_api <- function(bounding_box_shp, amenities= "", shops = "", process = TRUE, drop_unnamed_elements = TRUE) {

  if (all(shops == "") & all(amenities == "")) stop ("Must provide character vector of shop or amenity key-values.")

  osm_query <- osmdata::opq(bbox = sf::st_bbox(bounding_box_shp), timeout = 10000)

  if (shops != ""){
    shops_query <- paste0("\"shop\"=\"", shops, "\"" )
  }  else {
    shops_query <- NULL
  }

  if (amenities[[1]] != "") {
    amenities_query <- paste0("\"amenity\"=\"", amenities, "\"" )
  } else {
    amenities_query <- NULL
  }

  osm_query <- osmdata::add_osm_features(osm_query, features = c(shops_query, amenities_query))

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


    # define columns to select
    columns_to_select <- c("osm_id", "name", "shop", "amenity", "brand", "addr.street", "addr.housenumber", "addr.city", "addr.postcode")

    osm_pts <- osm_pts |>
      dplyr::as_tibble() |>
      sf::st_as_sf() |>
      dplyr::select(dplyr::any_of(columns_to_select))

    osm_poly_centroids <- osm_polys |>
      dplyr::as_tibble() |>
      sf::st_as_sf()

    sf::st_agr(osm_poly_centroids) <- "constant"

    osm_poly_centroids <- osm_poly_centroids |>
      dplyr::select(dplyr::any_of(columns_to_select)) |>
      sf::st_centroid()


    # combine points and polygons
    # create a new column called "type" that combines shop and amenity into one value
    result <- dplyr::bind_rows(osm_pts, osm_poly_centroids) #|>
      #dplyr::mutate(type = dplyr::if_else((amenity %in% amenities),  amenity, shop), .before = 3) |>
      #dplyr::filter(!is.na(type)) |>
     # sf::st_transform(crs = "WGS84")

    if (drop_unnamed_elements){
      result <- dplyr::filter(result, !is.na(name))
    }
  }

  return (result)
}
