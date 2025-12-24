#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom rlang .data
#' @importFrom rlang !!
## usethis namespace: end
NULL

# Register data objects to silence R CMD check warnings
utils::globalVariables(c(
  "districts",
  "survey_types",
  "wos_md_template"
))
