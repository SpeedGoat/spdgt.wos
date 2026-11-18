#' Read observations from database
#'
#' @param species the name of the species targeted by the survey
#' @param survey_type the type of survey conducted; must match one of the
#' survey types in the `survey_types` data set
#' @param analysis_unit the name of the analysis unit surveyed
#' @param bio_year the biological year of the survey, for the winter of
#' 2024-2025 the year of the survey is 2024
#'
#' @details
#' This function is a thin wrapper for `spdgt.sight::read_entries()` with
#' certain options hard-coded for Wildlife Observation System (WOS) data.
#'
#' When the user is uncertain about the survey type it is recommended to
#' use the spdgt.core function `spdgt.core::lkup_survey_types()` to view the
#' names of the survey types that can be used. Similarly, the user can lookup
#' analysis units using `spdgt.core::lkup_dau()`. For all of these arguments
#' the name is  what is required as an input.
#'
#' If the desire is to view observations data it is recommended to just use
#' `spdgt.sight::read_entries()` directly so that the user can set the various
#' options as needed.
#'
#' @returns A data frame of observations
#'
#' @examples
#' \dontrun{
#' # Read in some mule deer composition data
#' md_data <- wos_read(
#'   species = "Mule Deer",
#'   survey_type = "Composition",
#'   analysis_unit = "Paintrock 207",
#'   bio_year = 2021
#' )
#' }
wos_read <- function(species, survey_type, analysis_unit, bio_year) {
  ids <- spdgt.sight:::lookup_by_name(
    species = species,
    analysis_unit = analysis_unit,
    survey_type = survey_type
  )

  spdgt.sight::sight_read_entries_id(
    survey_type_id = ids$survey_type_id,
    analysis_unit_id = ids$dau_id,
    bio_year = bio_year,
    pages = list("omit" = 1)
  )
}
