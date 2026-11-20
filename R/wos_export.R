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
#' It validates every argument before calling the API. If no observations are
#' found for the specified parameters, a warning is issued and an empty WOS
#' template data frame is returned (and written to `out_file`, if given).
#'
#' For more details check the documentation for `wos_read()`, `wos_format()`,
#' and `wos_write_xlsx()`.
#'
#' @returns A tibble formatted for WOS import, as from `wos_format()`
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
  check_string_input(analysis_unit, "analysis_unit")
  check_bio_year(bio_year)
  check_observer(observer)
  check_district(district)
  check_survey_type(survey_type)

  if (!is.null(out_file)) {
    check_string_input(out_file, "out_file")
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
