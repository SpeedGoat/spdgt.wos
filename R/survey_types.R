#' Survey types data set
#'
#' The survey types that can be exported to the Wildlife Observation System
#' (WOS) and the WOS activity code each one is reported under. Survey types are
#' not species-specific here. When reading data, the name is matched to the
#' species' own survey type in SpeedGoat.
#'
#' @format A data frame with 2 rows and 2 variables:
#' \describe{
#' \item{survey_type}{The type of survey conducted.}
#' \item{activity_code}{The WOS activity code for observations of the survey's
#' target species; see `activity_codes`.}
#' }
#' @source Created from internal documentation.
"survey_types"
