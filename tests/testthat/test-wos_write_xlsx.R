test_that("wos_export validates inputs before processing", {

  # 1. Test Invalid Observer Format
  # Regex changed to ".*" to handle backticks around 'observer'
  expect_error(
    wos_export(
      species = "Mule Deer",
      survey_type = "Composition",
      analysis_unit = "Unit 1",
      bio_year = 2021,
      observer = "Jane",
      district = "Pinedale Region"
    ),
    "Invalid .*observer.* format"
  )

  # 2. Test Invalid District
  expect_error(
    wos_export(
      species = "Mule Deer",
      survey_type = "Composition",
      analysis_unit = "Unit 1",
      bio_year = 2021,
      observer = "Jane Doe",
      district = "Mars Region"
    ),
    "District .* not found"
  )

  # 3. Test Invalid Year
  # Regex handles backticks around 'bio_year'
  expect_error(
    wos_export(
      species = "Mule Deer",
      survey_type = "Composition",
      analysis_unit = "Unit 1",
      bio_year = "2021",
      observer = "Jane Doe",
      district = "Pinedale Region"
    ),
    ".*bio_year.* must be a single numeric"
  )
})

test_that("wos_export validates survey configuration (Species/Type match)", {

  expect_error(
    wos_export(
      species = "Mule Deer",
      survey_type = "InvalidType",
      analysis_unit = "Unit 1",
      bio_year = 2021,
      observer = "Jane Doe",
      district = "Pinedale Region"
    ),
    "Survey type .* not found"
  )
})

test_that("wos_export handles empty data gracefully", {

  # 1. Create a mock for wos_read that returns an empty dataframe
  m_read <- mockery::mock(tibble::tibble())

  # 2. Stub wos_read inside wos_export
  mockery::stub(wos_export, "wos_read", m_read)

  # 3. Run wos_export
  # Expect a warning about no observations
  expect_warning(
    result <- wos_export(
      species = "Mule Deer",
      survey_type = "Composition",
      analysis_unit = "Unit 1",
      bio_year = 2021,
      observer = "Jane Doe",
      district = "Pinedale Region"
    ),
    "Empty dataset provided"
  )

  # 4. Expect the empty template to be returned
  expect_equal(result, wos_template)

  # 5. Verify the mock was called
  mockery::expect_called(m_read, 1)
})

test_that("wos_export handles unexpected data gracefully", {

  # 1. Create a mock for wos_read that returns an empty dataframe
  m_read <- mockery::mock(iris)

  # 2. Stub wos_read inside wos_export
  mockery::stub(wos_export, "wos_read", m_read)

  # 3. Run wos_export
  # Expect a warning about no observations
  expect_warning(
    result <- wos_export(
      species = "Mule Deer",
      survey_type = "Composition",
      analysis_unit = "Unit 1",
      bio_year = 2021,
      observer = "Jane Doe",
      district = "Pinedale Region"
    ),
    "Missing column"
  )

  # 4. Expect the empty template to be returned
  expect_equal(result, wos_template)

  # 5. Verify the mock was called
  mockery::expect_called(m_read, 1)
})

test_that("wos_write_xlsx works as expected", {

  # 1. Create Synthetic Data (similar to wos_format tests)
  fake_metadata <- tibble::tibble(
    juvenile_males = 1,
    sub_males = 2,
    adult_males = 2,
    other_males = 0
  )

  fake_data <- tibble::tibble(
    species = "Mule Deer",
    is_target_species = TRUE,
    total = 10,
    males = 5,
    females = 3,
    youngs = 2,
    unclass = 0,
    date = as.Date("2021-12-01"),
    latitude = 40.5,
    longitude = -105.5,
    metadata = list(fake_metadata)
  )

  # 2. Mock wos_read to return this fake data
  m_read <- mockery::mock(fake_data)
  mockery::stub(wos_export, "wos_read", m_read)

  # 3. Run wos_export
  result <- wos_export(
    species = "Mule Deer",
    survey_type = "Composition",
    analysis_unit = "Unit 1",
    bio_year = 2021,
    observer = "Jane Doe",
    district = "Pinedale Region"
  )

  # 4. Run wos_write_xlsx
  tf <- tempfile(fileext = ".xlsx")
  wwx_out <- wos_write_xlsx(result, tf)

  # 5. Verify result matches input
  expect_identical(result, wwx_out)

  # 6. Verify file was created
  expect_true(file.exists(tf))

  # 7. Verify that the newline modification was applied
  td <- tempfile()
  utils::unzip(tf, exdir = td)
  wwx_xml <- readChar(file.path(td, "xl/worksheets/sheet1.xml"), 100)
  unlink(td, recursive = TRUE)
  unlink(tf)
  expect_true(grepl(">\r\n<worksheet", wwx_xml))

})
