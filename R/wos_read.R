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
#' This function is a thin wrapper for `spdgt.sight::sight_read_entries()` with
#' certain options hard-coded for Wildlife Observation System (WOS) data.
#'
#' Every observation recorded on the survey is returned: the target species and
#' any incidental observations of other species, which WOS also accepts. The
#' `is_target_species` column distinguishes the two.
#'
#' The API's `species` filter applies to the animal observed, so it cannot be
#' used here without dropping incidentals. Instead `species` selects the
#' survey: survey types belong to one species, so entries are kept only when
#' their `survey_type_id` is that species' survey type. This stops a survey of
#' another species that shares the analysis unit name from being mixed in.
#'
#' When the user is uncertain about the survey type it is recommended to
#' use `spdgt.core::lkup_survey_type()` to view the names of the survey types
#' that can be used. Similarly, the user can lookup analysis units using
#' `spdgt.core::lkup_dau()`. For all of these arguments the name is what is
#' required as an input.
#'
#' If the desire is to view observations data it is recommended to just use
#' `spdgt.sight::sight_read_entries()` directly so that the user can set the
#' various options as needed.
#'
#' @returns A tibble of observations, one row per entry
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
#' @export
wos_read <- function(species, survey_type, analysis_unit, bio_year) {

  check_string_input(species, "species")
  check_string_input(survey_type, "survey_type")
  check_string_input(analysis_unit, "analysis_unit")
  check_bio_year(bio_year)

  type_ids <- spdgt.core::lkup_survey_type(
    species_name = species,
    survey_type_name = survey_type
  )$id

  if (!length(type_ids)) {
    cli::cli_abort(
      c("No {.val {survey_type}} survey type found for {.val {species}}.",
        "i" = "See {.code spdgt.core::lkup_survey_type({.val {species}})}.")
    )
  }

  entries <- spdgt.sight::sight_read_entries(
    survey_type = survey_type,
    analysis_unit = analysis_unit,
    bio_year = bio_year,
    pages = list("omit" = 1)
  )

  dplyr::filter(entries, .data$survey_type_id %in% .env$type_ids)

}
