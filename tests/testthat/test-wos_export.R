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
    "Invalid survey configuration"
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
    "No observations found"
  )

  # 4. Expect the empty template to be returned
  expect_equal(result, wos_md_template)

  # 5. Verify the mock was called
  mockery::expect_called(m_read, 1)
})

test_that("wos_export integrates read and format correctly (Happy Path)", {

  # 1. Create Synthetic Data (similar to wos_format tests)
  fake_metadata <- tibble::tibble(
    juvenile_males = 1,
    sub_males = 2,
    adult_males = 2,
    other_males = 0
  )

  fake_data <- tibble::tibble(
    species = "Mule Deer",
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

  # 4. Verify Result
  expect_equal(nrow(result), 1)
  expect_equal(result$observer, "Jane Doe")
  expect_equal(result$taxon, "Mule Deer")

  # 5. Verify Mock was called with correct arguments
  args <- mockery::mock_args(m_read)[[1]]
  expect_equal(args$species, "Mule Deer")
  expect_equal(args$bio_year, 2021)
})
