## code to prepare data goes here


ons_shp_gen2 <- sf::read_sf("data-raw/ons_shp_gen2/ons_shp_gen2.shp")
ons_shp_gen2 <- sf::st_transform(ons_shp_gen2, crs = "WGS84")

usethis::use_data(ons_shp_gen2, overwrite = TRUE)

ons_shp_gen3 <- sf::read_sf("data-raw/ons_shp_gen3/Final_Gen3_Sep2022.shp")
ons_shp_gen3 <- sf::st_transform(ons_shp_gen3, crs = "WGS84")
usethis::use_data(ons_shp_gen3, overwrite = TRUE)


# 2021 Statscan census areas
download.file(url = "https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/files-fichiers/ldb_000b21a_e.zip",
              dest = "data-raw/shapefiles/temp/ldb_000b21a_e.zip")

unzip("data-raw/shapefiles/temp/ldb_000b21a_e.zip", exdir = "data-raw/shapefiles/temp")

dbs_all <- sf::read_sf("data-raw/shapefiles/temp/ldb_000b21a_e.shp")
ottawa_shp_dbs <- dplyr::filter(dbs_all, stringr::str_detect(DBUID, "^3506"))
ottawa_shp_dbs <- sf::st_transform(ottawa_shp_dbs, crs="WGS84")

usethis::use_data(ottawa_shp_dbs, overwrite = TRUE)

# # optional checks
#ottawa_shp_dbs
#ggplot2::ggplot(ottawa_shp_dbs ) + ggplot2::geom_sf()


# clean up temp files
lapply(paste0("data-raw/shapefiles/temp/", list.files("data-raw/shapefiles/temp")), file.remove)

