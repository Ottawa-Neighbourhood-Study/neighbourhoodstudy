## code to prepare data goes here


ons_shp_gen2 <- sf::read_sf("data-raw/ons_shp_gen2/ons_shp_gen2.shp")
ons_shp_gen2 <- sf::st_transform(ons_shp_gen2, crs = "WGS84")

usethis::use_data(ons_shp_gen2, overwrite = TRUE)

ons_shp_gen3 <- sf::read_sf("data-raw/ons_shp_gen3/Gen3_with_rural_Feb2023_final.shp")
ons_shp_gen3 <- sf::st_transform(ons_shp_gen3, crs = "WGS84")
ons_shp_gen3 <- sf::st_make_valid(ons_shp_gen3)
usethis::use_data(ons_shp_gen3, overwrite = TRUE)

##########################################################################################
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




############################################
# Pseudo Households: only type 3 and 4, for on-road points
#
# --------------------+----------------------------------------------------------------------
#   Field               |  Description
# --------------------+----------------------------------------------------------------------
#   PHH_ID              |  Unique identifier for pseudo-household (PHH) representative point
# Type                |  PHH Type:
#   |    1 = Centroid of a 2016 Census dissemination block
# |    2 = Atlas of Canada Placename point
# |    3 = 2016 Census Road Network Address Range Left
# |    4 = 2016 Census Road Network Address Range Right
# |    5 = Previous representative point Left
# |    6 = Previous representative point Right
# |    8 = PHH null points added on highways
# Pop2016             |  PHH representative population
# TDwell2016_TLog2016 |  PHH representative total private dwellings
# URDwell2016_RH2016  |  PHH representative private dwellings occupied by usual residents
# DBUID_Ididu         |  2016 Census dissemination block
# HEXUID_IdUHEX       |  Hexagon identifier
# Pruid_Pridu         |  Province or territory identifier
# Latitude            |  Latitude for the PHH representative point
# Longitude           |  Longitude for the PHH representative point
library(sf)
library(tidyverse)

download.file(url = "https://www.ic.gc.ca/eic/site/720.nsf/vwapj/PHH_Data_ShapeFile.zip/$file/PHH_Data_ShapeFile.zip",
              dest = "data-raw/shapefiles/temp/PHH_Data_ShapeFile.zip")

unzip("data-raw/shapefiles/temp/PHH_Data_ShapeFile.zip", exdir = "data-raw/shapefiles/temp")

ontario <- sf::read_sf("data-raw/shapefiles/temp/PHH_Data_ShapeFile/PHH-ON.shp")

intersects <- ontario %>%

  #head() %>%
  sf::st_transform(crs="WGS84")  %>%
  sf::st_make_valid() %>%
  sf::st_intersects(sf::st_make_valid(neighbourhoodstudy::ons_shp_gen3))

i <- purrr::map(intersects, length)


ottawa_phhs <- ontario %>%
  dplyr::mutate(inscope = unlist(i)) %>%
  dplyr::filter(inscope == 1) %>%
  dplyr::select(-inscope) %>%
  sf::st_transform(crs="WGS84") %>%
  dplyr::filter(Type %in% c(3,4))

usethis::use_data(ottawa_phhs, overwrite = TRUE)



# clean up temp files
lapply(paste0("data-raw/shapefiles/temp/", list.files("data-raw/shapefiles/temp")), file.remove)
