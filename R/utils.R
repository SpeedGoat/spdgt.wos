check_string_input <- function(arg, arg_name) {
  if (!is.character(arg) || length(arg) != 1) {
    cli::cli_abort("{.arg {arg_name}} must be a single character string.")
  }
}
