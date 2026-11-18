#' Read and format Wildlife Observation System (WOS) data
#'
#' @inheritParams wos_read
#' @inheritParams wos_format
#' @inheritParams wos_write_xlsx
#'
#' @details
#' This function combines `wos_read()`, `wos_format()`, and (optionally)
#' `wos_write_xlsx()` to read observations from the database and format them for
#' WOS import in a single step.
#'
#' It performs input validation on all parameters to ensure they are correctly
#' formatted and valid. If no observations are found for the specified
#' parameters, a warning is issued and an empty WOS template data frame is
#' returned.
#'
#' For more details check the documentation for `wos_read()`, `wos_format()`,
#' and `wos_write_xlsx()`.
#'
#' @returns A data frame formatted for WOS import
#' @export
#'
#' @examples
#' \dontrun{
#' # Read and format some mule deer composition data for WOS
#' md_wos <- wos_export(
#'   species = "Mule Deer",
#'   survey_type = "Composition",
#'   analysis_unit = "Paintrock 207",
#'   bio_year = 2021,
#'   observer = "Jane Doe",
#'   district = "Cody Region"
#' )
#' }
wos_export <- function(species,
                       survey_type,
                       analysis_unit,
                       bio_year,
                       observer,
                       district,
                       out_file = NULL) {

  check_string_input(species, "species")
  check_string_input(survey_type, "survey_type")
  check_string_input(analysis_unit, "analysis_unit")
  check_string_input(district, "district")
  check_string_input(observer, "observer")

  if (!is.null(out_file)) {
    check_string_input(out_file, "out_file")
  }

  # Check bio_year is a single number
  if (!is.numeric(bio_year) || length(bio_year) != 1) {
    cli::cli_abort("{.arg bio_year} must be a single numeric year (e.g. 2021).")
  }

  if (!grepl("^[A-Za-z'-]+\\s[A-Za-z'-]+$", trimws(observer))) {
    cli::cli_abort(
      c("Invalid {.arg observer} format: {.val {observer}}",
        "i" = "Must be 'First Last' (e.g., 'Jane Doe', 'Mary-Anne O'Connor').")
    )
  }

  if (!district %in% names(districts)) {
    cli::cli_abort(
      c("District {.val {district}} not found.",
        "i" = "Available districts are in the {.code districts} dataset.")
    )
  }

  if (!survey_type %in% survey_types$survey_type) {
    cli::cli_abort(
      c("Survey type {.val {survey_type}} not found.",
        "i" = "Available survey_types are in the {.code survey_types} dataset.")
    )
  }

  data <- wos_read(
    species = species,
    survey_type = survey_type,
    analysis_unit = analysis_unit,
    bio_year = bio_year
  )

  out <- wos_format(
    x = data,
    observer = observer,
    district = district,
    survey_type = survey_type
  )

  if (!is.null(out_file)) {
    wos_write_xlsx(out, out_file)
  }

  out

}
