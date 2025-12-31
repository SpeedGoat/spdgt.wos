#' Read observations from database
#'
#' @param species the name of the species targeted by the survey
#' @param survey_type the type of survey conducted; must match one of the
#' survey types in the `survey_types` data set for the species
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
#' analysis units using `spdgt.core::lkup_dau()`. Species names can be found
#' using `spdgt.core::lkup_species()`. For all of these arguments the name is
#' what is required as an input.
#'
#' Note that `spdgt.sight::read_entries()` has an argument called
#' `is_target_species`, which is set to `TRUE` in this function. This means that
#' only observations of the target species for the survey will be returned. The
#' target species is mule deer if it is a mule deer survey type and so
#' observations of other animals (e.g. moose) will be removed prior to returning
#' the data to the user.
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
  spdgt.sight::read_entries(
    species = species,
    survey_type = survey_type,
    analysis_unit = analysis_unit,
    bio_year = bio_year,
    is_target_species = TRUE, # Subject of debate
    pages = list("omit" = 1)
  )
}
