check_string_input <- function(arg, arg_name) {
  if (!is.character(arg) || length(arg) != 1 || is.na(arg) || !nzchar(arg)) {
    cli::cli_abort(
      "{.arg {arg_name}} must be a single, non-empty character string."
    )
  }
}

# The lookup data sets are lazy data, which lives in the attached package
# environment rather than the namespace. Package code that names them directly
# therefore only finds them after library(spdgt.wos); a call through
# spdgt.wos::wos_export() fails with "object 'districts' not found".
# getExportedValue() resolves lazy data from the namespace without attaching,
# and keeps a single copy of each data set (no sysdata.rda to drift).
pkg_data <- function(name) {
  getExportedValue("spdgt.wos", name)
}

check_observer <- function(observer) {
  check_string_input(observer, "observer")
  if (!grepl("^[A-Za-z'-]+\\s+[A-Za-z'-]+$", trimws(observer))) {
    cli::cli_abort(
      c("Invalid {.arg observer} format: {.val {observer}}",
        "i" = "Must be 'First Last' (e.g., 'Jane Doe', 'Mary-Anne O'Connor').")
    )
  }
}

check_district <- function(district) {
  check_string_input(district, "district")
  if (!district %in% names(pkg_data("districts"))) {
    cli::cli_abort(
      c("District {.val {district}} not found.",
        "i" = "Available districts are in the {.code districts} dataset.")
    )
  }
}

check_survey_type <- function(survey_type) {
  check_string_input(survey_type, "survey_type")
  if (!survey_type %in% pkg_data("survey_types")$survey_type) {
    cli::cli_abort(
      c("Survey type {.val {survey_type}} not found.",
        "i" = "Available survey types are in the {.code survey_types} dataset.")
    )
  }
}

check_bio_year <- function(bio_year) {
  if (!is.numeric(bio_year) || length(bio_year) != 1 || is.na(bio_year) ||
        bio_year != round(bio_year)) {
    cli::cli_abort("{.arg bio_year} must be a single numeric year (e.g. 2021).")
  }
}
