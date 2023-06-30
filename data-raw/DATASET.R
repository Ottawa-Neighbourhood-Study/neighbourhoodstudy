## code to prepare data goes here

ons_gen2_shp <- sf::read_sf("data-raw/ons_shp_gen2/ons_shp_gen2.shp")
ons_gen2_shp <- sf::st_transform(ons_shp_gen2, crs = "WGS84")

usethis::use_data(ons_gen2_shp, overwrite = TRUE)

ons_gen3_shp <- sf::read_sf("data-raw/ons_shp_gen3/Gen3_with_rural_Feb2023_final.shp")
ons_gen3_shp <- sf::st_transform(ons_gen3_shp, crs = "WGS84")
ons_gen3_shp <- sf::st_make_valid(ons_gen3_shp)
ons_gen3_shp$ONS_ID <- as.character(ons_gen3_shp$ONS_ID)
usethis::use_data(ons_gen3_shp, overwrite = TRUE)

##########################################################################################
# 2021 Statscan census areas
# Dissemination blocks
download.file(url = "https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/files-fichiers/ldb_000b21a_e.zip",
              dest = "data-raw/shapefiles/temp/ldb_000b21a_e.zip")

unzip("data-raw/shapefiles/temp/ldb_000b21a_e.zip", exdir = "data-raw/shapefiles/temp")

dbs_all <- sf::read_sf("data-raw/shapefiles/temp/ldb_000b21a_e.shp")
ottawa_dbs_shp <- dplyr::filter(dbs_all, stringr::str_detect(DBUID, "^3506"))
ottawa_dbs_shp <- sf::st_transform(ottawa_dbs_shp, crs="WGS84")

usethis::use_data(ottawa_dbs_shp2021, overwrite = TRUE)

# Dissemination areas

download.file(url = "https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/files-fichiers/lda_000b21a_e.zip",
              dest = "data-raw/shapefiles/temp/lda_000b21a_e.zip")

unzip("data-raw/shapefiles/temp/lda_000b21a_e.zip", exdir = "data-raw/shapefiles/temp")

das_all <- sf::read_sf("data-raw/shapefiles/temp/lda_000b21a_e.shp")
ottawa_das_shp2021 <- dplyr::filter(das_all, stringr::str_detect(DAUID, "^3506"))
ottawa_das_shp2021 <- sf::st_transform(ottawa_das_shp2021, crs="WGS84")

#ottawa_das_shp2021 |> ggplot2::ggplot() + ggplot2::geom_sf()

usethis::use_data(ottawa_das_shp2021, overwrite = TRUE)

# clean up temp files
lapply(paste0("data-raw/shapefiles/temp/", list.files("data-raw/shapefiles/temp")), file.remove)



### PSEUDOHOUSEHOLDS
library(tidyverse)
library(sf)

ottawa_phhs <- sf::read_sf("data-raw/ottawa_phhs/3506-phhs-2023-04-27.shp") |>
  sf::st_transform(crs="WGS84")

#ggplot() + geom_sf(data = ottawa_phhs)

usethis::use_data(ottawa_phhs, overwrite = TRUE)


#### STATISTICS CANADA CUSTOM DATA CUTS FOR ONS GEN3 NEIGHBOURHOODS
library(tidyverse)
custom <- readr::read_csv("data-raw/statscan-custom-geo/StatsCanCustomGeo_Population Report_2021.csv")

ons_gen3_pop2021 <- custom |>
  dplyr::filter(stringr::str_detect(Name, "ONS2022")) |>
  dplyr::mutate(ONS_ID = stringr::str_extract(Name, "(?<=\\()\\d{4}"), .before = 1) |>
  dplyr::mutate(Name = stringr::str_extract(Name, "(?<=- ).*(?= \\()")) |>
  dplyr::left_join(neighbourhoodstudy::ons_gen3_shp) |>
  dplyr::filter(ONS_Region == "OTTAWA") |>
  dplyr::select(-SHAPE_Leng, -SHAPE_Area, -ONS_Region, -geometry, -Name, -join_field)

usethis::use_data(ons_gen3_pop2021, overwrite = TRUE)




### DISSEMINATION-BLOCK LEVEL DATA FROM THE 2021 GEOGRAPHIC ATTRIBUTE FILE

# The Geographic Attribute File contains geographic data at the dissemination
# block level. The file includes geographic codes, land area, population and
# dwelling counts, names, unique identifiers, DGUIDs and types, where
# applicable.

# https://www150.statcan.gc.ca/n1/pub/92-151-g/92-151-g2021001-eng.htm

library(tidyverse)
download.file(url = "https://www12.statcan.gc.ca/census-recensement/2021/geo/aip-pia/attribute-attribs/files-fichiers/2021_92-151_X.zip",
              dest = "data-raw/temp/2021_92-151_X.zip")

unzip("data-raw/temp/2021_92-151_X.zip", exdir = "data-raw/temp/geoattribute")

geo <- readr::read_csv("data-raw/temp/geoattribute/2021_92-151_X.csv")

ottawa_dbs_pop2021 <- geo |>
  dplyr::filter(DBUID_IDIDU %in% neighbourhoodstudy::ottawa_dbs_shp$DBUID) |>
  dplyr::select(DBUID = DBUID_IDIDU,
#                DAUID = DAUID_ADIDU, # DAUID is first 8 characters of DBUID
                dbpop2021 = DBPOP2021_IDPOP2021,
                dbtdwell2021 = DBTDWELL2021_IDTLOG2021,
                dburdwell2021 = DBURDWELL2021_IDRHLOG2021,
                dbarea2021 = DBAREA2021_IDSUP2021) |>
  dplyr::mutate(DBUID = as.character(DBUID))

usethis::use_data(ottawa_dbs_pop2021, overwrite = TRUE)





# RETAINED FOR ARCHIVAL PURPOSES: CODE TO USE OLD INDUSTRY CANADA PSEUDOHOUSEHOLDS
# ############################################
# # Pseudo Households: only type 3 and 4, for on-road points
# #
# # --------------------+----------------------------------------------------------------------
# #   Field               |  Description
# # --------------------+----------------------------------------------------------------------
# #   PHH_ID              |  Unique identifier for pseudo-household (PHH) representative point
# # Type                |  PHH Type:
# #   |    1 = Centroid of a 2016 Census dissemination block
# # |    2 = Atlas of Canada Placename point
# # |    3 = 2016 Census Road Network Address Range Left
# # |    4 = 2016 Census Road Network Address Range Right
# # |    5 = Previous representative point Left
# # |    6 = Previous representative point Right
# # |    8 = PHH null points added on highways
# # Pop2016             |  PHH representative population
# # TDwell2016_TLog2016 |  PHH representative total private dwellings
# # URDwell2016_RH2016  |  PHH representative private dwellings occupied by usual residents
# # DBUID_Ididu         |  2016 Census dissemination block
# # HEXUID_IdUHEX       |  Hexagon identifier
# # Pruid_Pridu         |  Province or territory identifier
# # Latitude            |  Latitude for the PHH representative point
# # Longitude           |  Longitude for the PHH representative point
# library(sf)
# library(tidyverse)
#
# download.file(url = "https://www.ic.gc.ca/eic/site/720.nsf/vwapj/PHH_Data_ShapeFile.zip/$file/PHH_Data_ShapeFile.zip",
#               dest = "data-raw/shapefiles/temp/PHH_Data_ShapeFile.zip")
#
# unzip("data-raw/shapefiles/temp/PHH_Data_ShapeFile.zip", exdir = "data-raw/shapefiles/temp")
#
# ontario <- sf::read_sf("data-raw/shapefiles/temp/PHH_Data_ShapeFile/PHH-ON.shp")
#
# intersects <- ontario %>%
#
#   #head() %>%
#   sf::st_transform(crs="WGS84")  %>%
#   sf::st_make_valid() %>%
#   sf::st_intersects(sf::st_make_valid(neighbourhoodstudy::ons_shp_gen3))
#
# i <- purrr::map(intersects, length)
#
#
# ottawa_phhs_shp <- ontario %>%
#   dplyr::mutate(inscope = unlist(i)) %>%
#   dplyr::filter(inscope == 1) %>%
#   dplyr::select(-inscope) %>%
#   sf::st_transform(crs="WGS84") %>%
#   dplyr::filter(Type %in% c(3,4))
#
# usethis::use_data(ottawa_phhs_shp, overwrite = TRUE)
#
#
#
# # clean up temp files
# lapply(paste0("data-raw/shapefiles/temp/", list.files("data-raw/shapefiles/temp")), file.remove)
