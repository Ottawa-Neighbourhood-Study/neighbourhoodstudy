## code to prepare data goes here


ons_shp_gen2 <- sf::read_sf("data-raw/ons_shp_gen2/ons_shp_gen2.shp")
ons_shp_gen2 <- sf::st_transform(ons_shp_gen2, crs = "WGS84")

usethis::use_data(ons_shp_gen2, overwrite = TRUE)

ons_shp_gen3 <- sf::read_sf("data-raw/ons_shp_gen3/Final_Gen3_Sep2022.shp")
ons_shp_gen3 <- sf::st_transform(ons_shp_gen3, crs = "WGS84")
usethis::use_data(ons_shp_gen3, overwrite = TRUE)
