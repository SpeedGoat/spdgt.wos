#' Save spreadsheet file for Wildlife Observation System (WOS) import
#'
#' @param x data frame of observations as returned by \code{wos_format()}
#' @param out_file filepath where the data will be saved
#'
#' @details
#' The WOS2 upload form only accepts .xslx files written in a certain way. This
#' function uses the \code{openxslx2} package to ensure the output is compatible
#' with the WOS upload web form. Calling this function when either of
#' \code{openxslx2} or \code{withr} is not installed produces an error.
#'
#' @returns The path to the exported file, invisibly
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
#'
#' # save the formatted data to xlsx for uploading
#' wos_write_xlsx(md_wos, "md207_comp_2021_WOS.xlsx")
#'
#' }
wos_write_xlsx <- function(x, out_file) {

  # check dependencies
  if (!requireNamespace("openxlsx2", quietly = TRUE)) {
    cli::abort("package {.pkg openxlsx2} is required for saving xlsx files")
  }
  if (!requireNamespace("withr", quietly = TRUE)) {
    cli::abort("package {.pkg withr} is required for saving xlsx files")
  }

  # write preliminary xlsx
  openxlsx2::wb_workbook() |>
    openxlsx2::wb_add_worksheet("WOS Input Sheet") |>
    openxlsx2::wb_add_data(x = x, na.strings = "", inline_strings = FALSE) |>
    openxlsx2::wb_save(out_file)
  
  # unzip
  tf <- tempfile()
  unzip(out_file, exdir = tf)

  # insert newline
  s1_path <- file.path(tf, "xl/worksheets/sheet1.xml")
  rl <- suppressWarnings(readLines(s1_path)) # incomplete final line...
  rl <- sub("><worksheet", ">\r\n<worksheet", rl)
  f <- file(s1_path, open = "wb")
  cat(rl, file = f)
  close(f)

  # rezip
  unlink(out_file)
  withr::with_dir(
    tf,
    utils::zip(out_file, flags = "-qr9X", files = list.files())
  )
  unlink(tf, recursive = TRUE)

  invisible(out_file)

}
