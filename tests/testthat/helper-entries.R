# One API entry, shaped like spdgt.sight::sight_read_entries() output:
# `metadata` is a list column of one-row tibbles holding a `mappings` list
# column of classification counts. `mappings = NULL` leaves the column out.
make_entry <- function(species = "Mule Deer",
                       is_target_species = TRUE,
                       total = 10, males = 5, females = 3, youngs = 2,
                       unclass = 0,
                       mappings = tibble::tibble(
                         juvenile_males = 1, sub_males = 2, adult_males = 2,
                         other_males = 0
                       ),
                       survey_type_id = 1L,
                       date = "2021-12-01") {
  meta <- tibble::tibble(notes = NA)
  if (!is.null(mappings)) meta$mappings <- list(mappings)
  tibble::tibble(
    species = species, is_target_species = is_target_species,
    survey_type_id = survey_type_id,
    total = total, males = males, females = females, youngs = youngs,
    unclass = unclass, date = date, latitude = 41.3, longitude = -105.6,
    metadata = list(meta)
  )
}

fmt <- function(x, survey_type = "Composition") {
  wos_format(x, "Jane Doe", "Cody Region", survey_type)
}

# wos_export() with wos_read() stubbed; arguments override export_args
export_args <- list(
  species = "Mule Deer", survey_type = "Composition",
  analysis_unit = "Unit 1", bio_year = 2021, observer = "Jane Doe",
  district = "Pinedale Region"
)

run_export <- function(..., read = mockery::mock(make_entry())) {
  mockery::stub(wos_export, "wos_read", read)
  args <- utils::modifyList(export_args, list(...))
  do.call(wos_export, args)
}

# Formatted rows: a target species observation and an incidental
wos_rows <- function() {
  dplyr::bind_rows(
    make_entry(),
    make_entry("Elk", FALSE, total = 4, males = 1, females = 3, youngs = 0,
               mappings = NULL)
  ) |>
    fmt()
}

sheet_xml <- function(path) {
  td <- tempfile()
  on.exit(unlink(td, recursive = TRUE))
  zip::unzip(path, exdir = td)
  f <- file.path(td, "xl", "worksheets", "sheet1.xml")
  readChar(f, file.size(f), useBytes = TRUE)
}
