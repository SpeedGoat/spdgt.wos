check_string_input <- function(arg, arg_name) {
  if (!is.character(arg) || length(arg) != 1) {
    cli::cli_abort("{.arg {arg_name}} must be a single character string.")
  }
}

#' Get WOS Template for a Species
#'
#' @param species Character string. The target species name.
#' @return A zero-row tibble with the correct WOS schema for that species.
#' @noRd
get_template <- function(species) {
  switch(
    species,
    "Mule Deer" = wos_md_template,
    {
      cli::cli_abort(
        "Species {.val {species}} not currently supported for WOS formatting."
      )
    }
  )

}
