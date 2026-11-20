#' Save spreadsheet file for Wildlife Observation System (WOS) import
#'
#' @param x data frame of observations as returned by `wos_format()`
#' @param out_file filepath where the data will be saved; must end in `.xlsx`.
#' An existing file is replaced.
#'
#' @details
#' The WOS2 upload form only accepts .xlsx files written in a certain way: the
#' worksheet XML must have a line break between its declaration and the
#' `<worksheet>` element, which no spreadsheet writer in R produces. This
#' function writes the workbook with `openxlsx2`, adds the line break, and
#' re-zips the file with the `zip` package, so it works on any machine without
#' Excel, Rtools or a system `zip` program.
#'
#' The file is written to a temporary location first and moved into place only
#' once it is complete, so a failure never leaves a broken file at `out_file`.
#'
#' @returns `x`, invisibly
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

  check_wos_data(x)
  check_string_input(out_file, "out_file")

  if (!grepl("\\.xlsx$", out_file, ignore.case = TRUE)) {
    cli::cli_abort(
      c("{.arg out_file} must end in {.file .xlsx}.",
        "x" = "Got {.file {basename(out_file)}}.")
    )
  }

  out_dir <- dirname(normalizePath(out_file, mustWork = FALSE))
  if (!dir.exists(out_dir)) {
    cli::cli_abort("Directory {.path {out_dir}} does not exist.")
  }
  out_path <- file.path(out_dir, basename(out_file))

  work <- tempfile("wos_xlsx_")
  dir.create(work)
  on.exit(unlink(work, recursive = TRUE), add = TRUE)

  raw_xlsx <- file.path(work, "raw.xlsx")
  openxlsx2::wb_workbook() |>
    openxlsx2::wb_add_worksheet("WOS Input Sheet") |>
    openxlsx2::wb_add_data(x = x, na.strings = "", inline_strings = FALSE) |>
    openxlsx2::wb_save(raw_xlsx)

  parts <- file.path(work, "parts")
  zip::unzip(raw_xlsx, exdir = parts)
  add_declaration_break(file.path(parts, "xl", "worksheets", "sheet1.xml"))

  # Build next to the destination so the final rename cannot cross devices
  staged <- tempfile("wos_", tmpdir = out_dir, fileext = ".xlsx")
  on.exit(unlink(staged), add = TRUE)
  # [Content_Types].xml first, as Excel and the WOS-tested output write it
  members <- list.files(parts, recursive = TRUE, all.files = TRUE)
  members <- c(
    intersect("[Content_Types].xml", members),
    sort(setdiff(members, "[Content_Types].xml"), method = "radix")
  )
  zip::zip(
    staged,
    files = members,
    root = parts,
    mode = "mirror"
  )

  if (!file.rename(staged, out_path)) {
    if (!file.copy(staged, out_path, overwrite = TRUE)) {
      cli::cli_abort("Could not write {.path {out_path}}.")
    }
  }

  invisible(x)

}

# WOS rejects worksheet XML whose declaration and root element share a line.
add_declaration_break <- function(path) {
  xml <- readChar(path, file.size(path), useBytes = TRUE)

  if (grepl("\\?>\r?\n<worksheet", xml, useBytes = TRUE)) {
    return(invisible(path))
  }
  if (!grepl("?><worksheet", xml, fixed = TRUE, useBytes = TRUE)) {
    cli::cli_abort(c(
      "Unexpected worksheet layout from {.pkg openxlsx2}.",
      "x" = "Cannot produce a file the WOS upload form accepts.",
      "i" = "Report this at {.url https://support.spdgt.com}."
    ))
  }

  xml <- sub("?><worksheet", "?>\r\n<worksheet", xml, fixed = TRUE,
             useBytes = TRUE)
  con <- file(path, open = "wb")
  on.exit(close(con))
  writeChar(xml, con, eos = NULL, useBytes = TRUE)
  invisible(path)
}

check_wos_data <- function(x) {
  if (!is.data.frame(x)) {
    cli::cli_abort(
      "{.arg x} must be a data frame, not {.obj_type_friendly {x}}."
    )
  }
  missing <- setdiff(colnames(pkg_data("wos_template")), colnames(x))
  if (length(missing)) {
    cli::cli_abort(c(
      "{.arg x} is not in WOS format.",
      "x" = "Missing column{?s}: {.field {missing}}.",
      "i" = "Format observations with {.fn wos_format} first."
    ))
  }
}
