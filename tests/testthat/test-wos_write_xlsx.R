test_that("wos_write_xlsx writes a WOS-compatible workbook", {
  x <- wos_rows()
  tf <- tempfile(fileext = ".xlsx")
  on.exit(unlink(tf))

  expect_identical(wos_write_xlsx(x, tf), x)
  expect_true(startsWith(sheet_xml(tf), paste0(
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\r\n<worksheet'
  )))
  expect_equal(zip::zip_list(tf)$filename[1], "[Content_Types].xml")
  expect_equal(openxlsx2::wb_get_sheet_names(openxlsx2::wb_load(tf)),
               c(`WOS Input Sheet` = "WOS Input Sheet"))

  back <- openxlsx2::read_xlsx(tf)
  expect_named(back, names(wos_template))
  expect_equal(back$taxon, c("Mule Deer", "Elk"))
  expect_equal(back$ma_adult_qty, c(4, 1))
})

test_that("wos_write_xlsx replaces an existing file and leaves no temp files", {
  td <- tempfile()
  dir.create(td)
  on.exit(unlink(td, recursive = TRUE))
  tf <- file.path(td, "out.xlsx")
  writeLines("old", tf)

  wos_write_xlsx(wos_rows(), tf)

  expect_equal(list.files(td), "out.xlsx")
  expect_equal(nrow(openxlsx2::read_xlsx(tf)), 2)
})

test_that("wos_write_xlsx writes the empty template", {
  tf <- tempfile(fileext = ".xlsx")
  on.exit(unlink(tf))
  wos_write_xlsx(wos_template, tf)
  expect_true(file.exists(tf))
})

test_that("wos_write_xlsx validates its arguments", {
  x <- wos_rows()
  expect_error(wos_write_xlsx(x, tempfile(fileext = ".csv")), "must end in")
  expect_error(wos_write_xlsx(x, file.path(tempfile(), "a.xlsx")),
               "does not exist")
  expect_error(wos_write_xlsx(iris, tempfile(fileext = ".xlsx")),
               "not in WOS format")
  expect_error(wos_write_xlsx("x", tempfile(fileext = ".xlsx")),
               "must be a data frame")
})

test_that("add_declaration_break is idempotent and refuses unknown layouts", {
  f <- tempfile()
  on.exit(unlink(f))

  writeChar('<?xml version="1.0"?><worksheet/>', f, eos = NULL)
  add_declaration_break(f)
  add_declaration_break(f)
  expect_equal(readChar(f, file.size(f)),
               '<?xml version="1.0"?>\r\n<worksheet/>')

  writeChar("<sheet/>", f, eos = NULL)
  expect_error(add_declaration_break(f), "Unexpected worksheet layout")
})
