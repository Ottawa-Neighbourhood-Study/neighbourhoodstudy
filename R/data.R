#' Ottawa Neighbourhood Study Spatial Boundaries (Gen2)
#'
#' The ONS Neighbourhood Boundaries were created by the Ottawa Neighbourhood Study
#' (ONS) to analyse population statistics and are not indicative of actual neighbourhood limits.
#'
#' Available publicly from the City of Ottawa: \url{https://open.ottawa.ca/datasets/32fe76b71c5e424fab19fec1f180ec18_0/explore}
#'
#' @family shapefiles
#' @seealso ons_shp_gen3
#'
"ons_gen2_shp"

#' Ottawa Neighbourhood Study Spatial Boundaries (Gen3)
#'
#' The ONS Neighbourhood Boundaries were created by the Ottawa Neighbourhood Study
#' (ONS) to analyse population statistics and are not indicative of actual neighbourhood limits.
#'
#' @family shapefiles
#' @seealso ons_shp_gen2
"ons_gen3_shp"



#' Pseudo-Households in Ottawa Created Using package `sliopt`
#'
#' This is a custom set of pseudohouseholds (PHHs) created for the Ottawa
#' Neighbourhood Study using an orignial methodology.
#'
#' The following description is from the Government of Canada:
#' https://open.canada.ca/data/en/dataset/b3a1d603-19ca-466c-ae95-b5185e56addf
#'
#' "The Pseudo-Household Demographic Distribution is a geospatial representative
#' distribution of demographic data (population and households) derived from the
#' Canadian Census from Statistics Canada. Demography is distributed within
#' Dissemination Blocks along roadways, providing a more accurate geospatial
#' distribution while still aligning with published Census geographies.
#' Pseudo-household demographics are currently used to calculate broadband
#' Internet service availability, but are equally applicable to other
#' disciplines requiring a spatial distribution of households or population."
#' @family shapefiles
"ottawa_phhs"

#' 2021 Statistics Canada Dissemination Blocks (DBs) in Ottawa
#'
#' https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/index2021-eng.cfm?year=21
#'
#'
#' @family shapefiles
"ottawa_dbs_shp2021"

#' 2021 Statistics Canada Dissemination Areas (DAs) in Ottawa
#'
#' https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/index2021-eng.cfm?year=21
#'
#'
#' @family shapefiles
"ottawa_das_shp2021"

#' Statistics Canada population statistics for ONS Gen3 Neighbourhoods
#'
#' SF_TotalPop	Total population, non-institutional and institutional residents, 100% Census data.
#' SF_NIPOP	Total non-institutional population in private households, 100% Census data.
#' SF_PTDWELL	Total number of private dwellings, 100% Census data.
#' SF_PODWELL_UR	Total number of private dwellings occupied by usual residents, 100% Census data.
#' LF_POP_PRIV	Total population in private households from long form, 25% Census data.
#' LF_Households	Total number of households, 25% Census data.
#' @seealso ons_shp_gen3
"ons_gen3_pop2021"


#' Statistics Canada populations for 2021 Dissemination Blocks (DBs) in Ottawa
#'
#' Data taken from the Geographic Attribute File
#' https://www12.statcan.gc.ca/census-recensement/2021/geo/aip-pia/attribute-attribs/index2021-eng.cfm
#'
#' Column names have been shortened for ease of use. These definitions are from the
#' record layout referenced below:
#'
#' dbpop21:	Number (9)	2021 Census dissemination block population.
#' dbtdwell2021:	Number (9)	2021 Census dissemination block total private dwellings.
#' dburbdwell2021: 	Number (9)	2021 Census private dwellings occupied by usual residents.
#' dbarea2021: 	Number (14.4)	2021 Census dissemination block land area.
#'
#' For record layout: https://www150.statcan.gc.ca/n1/pub/92-151-g/2021001/tbl/tbl4_1-eng.htm
#'
#' @seealso ottawa_dbs_shp
"ottawa_dbs_pop2021"

#' Max-Area Single-Link Indicator (SLI) from 2021 StatsCan DBs to Gen3 Neighbourhoods
#'
#' Dissemination Blocks are linked to the single ONS Gen3 neighbourhood they most
#' overlap.
#' @family slis
"sli_dbs_gen3_maxoverlap"
