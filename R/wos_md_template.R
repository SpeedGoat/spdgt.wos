#' WOS Mule Deer Data Template
#'
#' A tibble defining the schema required for importing Mule Deer survey data
#' into the WOS (Wildlife Observation System). This empty template ensures that
#' all necessary columns are present and correctly typed before data entry.
#'
#' @format A tibble with 0 rows and 47 variables:
#' \describe{
#'   \item{observer}{character. Name of the observer in "First Last" format.}
#'   \item{district}{integer. District identifier (e.g., 1).}
#'   \item{obs_month}{integer. Month of observation (MM).}
#'   \item{obs_year}{integer. Year of observation (YYYY).}
#'   \item{obs_day}{integer. Day of observation (DD).}
#'   \item{taxon}{character. Common name of the species observed.}
#'   \item{ma_adult_qty}{integer. Count of adult males.}
#'   \item{ma_year_qty}{integer. Count of yearling males.}
#'   \item{ma_juv_qty}{integer. Count of juvenile males.}
#'   \item{ma_unk_qty}{integer. Count of males of unknown age.}
#'   \item{ma_est_cnt_flag}{logical. TRUE if male counts are estimates, otherwise FALSE.}
#'   \item{ma_age}{numeric. Specific age of males observed, if known.}
#'   \item{fe_adult_qty}{integer. Count of adult females.}
#'   \item{fe_year_qty}{integer. Count of yearling females.}
#'   \item{fe_juv_qty}{integer. Count of juvenile females.}
#'   \item{fe_unk_qty}{integer. Count of females of unknown age.}
#'   \item{fe_est_cnt_flag}{logical. TRUE if female counts are estimates, otherwise FALSE.}
#'   \item{fe_age}{numeric. Specific age of females observed, if known.}
#'   \item{un_adult_qty}{integer. Count of adults of unknown sex.}
#'   \item{un_year_qty}{integer. Count of yearlings of unknown sex.}
#'   \item{un_juv_qty}{integer. Count of juveniles of unknown sex.}
#'   \item{un_unk_qty}{integer. Count of individuals of unknown sex and unknown age.}
#'   \item{un_est_cnt_flag}{logical. TRUE if unknown sex counts are estimates, otherwise FALSE.}
#'   \item{un_age}{numeric. Specific age of unknown sex individuals, if known.}
#'   \item{detection_type}{character. Method of detection (e.g., "Visual").}
#'   \item{hunt_area}{character. Optional hunt area identifier.}
#'   \item{sug_area}{character. Optional sub-unit game area; usually blank.}
#'   \item{degree_block}{character. Reserved for non-game birds; usually blank.}
#'   \item{habitat_type}{character. Habitat classification; usually blank.}
#'   \item{mortality_code}{character. Code indicating cause of death if applicable; usually blank.}
#'   \item{animal_activity}{character. Description of animal behavior; usually blank.}
#'   \item{observer_activity}{integer. Code representing observer's activity (e.g., 2 or 9).}
#'   \item{dwelling_feature}{character. Description of dwelling features; usually blank.}
#'   \item{dwell_othr}{character. Other dwelling details; usually blank.}
#'   \item{dwell_count}{numeric. Count related to dwellings; usually blank.}
#'   \item{dwell_est_cnt_flag}{logical. TRUE if dwelling count is an estimate; usually blank.}
#'   \item{dwell_perc_active}{numeric. Percentage of dwelling activity; usually blank.}
#'   \item{dwell_iden}{numeric. Dwelling identifier; usually blank.}
#'   \item{dwell_note}{character. Notes regarding dwellings; usually blank.}
#'   \item{utm_zone}{character. UTM zone; usually blank as lat/long are used.}
#'   \item{utm_easting}{numeric. UTM easting coordinate; usually blank.}
#'   \item{utm_northing}{numeric. UTM northing coordinate; usually blank.}
#'   \item{latitude}{numeric. Latitude in decimal degrees.}
#'   \item{longitude}{numeric. Longitude in decimal degrees.}
#'   \item{datum}{character. Geodetic datum used for coordinates (e.g., "WGS 84").}
#'   \item{source}{character. Data source identifier; usually blank.}
#'   \item{field_notes}{character. Additional notes from the field; usually blank.}
#' }
"wos_md_template"
