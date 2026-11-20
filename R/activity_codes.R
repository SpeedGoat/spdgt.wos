#' Activity codes data set
#'
#' A data set describing activity codes used in the Wildlife Observation System
#' (WOS) database, for reference. `wos_format()` reports target species
#' observations under the survey type's code (see `survey_types`) and
#' incidental observations as code 1, casual observation.
#'
#' @format A data frame with 14 rows and 2 variables:
#' \describe{
#' \item{activity_code}{The activity code used in WOS data upload.}
#' \item{activity_descr}{Textual description corresponding to the code.}
#' }
#' @source Created from internal documentation.
"activity_codes"
