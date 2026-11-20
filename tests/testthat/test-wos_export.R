test_that("wos_export validates inputs before reading", {
  read <- mockery::mock()
  expect_error(run_export(observer = "Jane", read = read),
               "Invalid .*observer")
  expect_error(run_export(district = "Mars Region", read = read),
               "District .* not found")
  expect_error(run_export(bio_year = "2021", read = read),
               "bio_year.* must be a single numeric")
  expect_error(run_export(survey_type = "InvalidType", read = read),
               "Survey type .* not found")
  expect_error(run_export(species = NA_character_, read = read), "species")
  expect_error(run_export(out_file = 1, read = read), "out_file")
  mockery::expect_called(read, 0)
})

test_that("wos_export reads and formats", {
  read <- mockery::mock(make_entry())
  out <- run_export(read = read)

  expect_equal(nrow(out), 1)
  expect_equal(out$observer, "Jane Doe")
  expect_equal(out$district, 1L)
  expect_equal(
    mockery::mock_args(read)[[1]],
    list(species = "Mule Deer", survey_type = "Composition",
         analysis_unit = "Unit 1", bio_year = 2021)
  )
})

test_that("wos_export returns the empty template when nothing is found", {
  expect_warning(
    out <- run_export(read = mockery::mock(tibble::tibble())),
    "Empty dataset"
  )
  expect_identical(out, wos_template)
})

test_that("wos_export writes out_file when given", {
  tf <- tempfile(fileext = ".xlsx")
  on.exit(unlink(tf))

  out <- run_export(out_file = tf)

  expect_true(file.exists(tf))
  expect_equal(openxlsx2::read_xlsx(tf)$taxon, out$taxon)
})
