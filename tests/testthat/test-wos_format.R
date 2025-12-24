test_that("wos_format handles Mule Deer 'Happy Path' correctly", {

  # 1. Create Synthetic Input Data
  # Metadata ONLY contains the specific male breakdown
  fake_metadata <- tibble::tibble(
    juvenile_males = 1, # Yearling
    sub_males = 2,      # Adult
    adult_males = 2,    # Adult
    other_males = 0     # Adult
  )

  # Parent data contains the broad counts
  input_data <- tibble::tibble(
    species = "Mule Deer",
    total = 10,
    males = 5,
    females = 3,
    youngs = 2,
    unclass = 0,
    date = as.Date("2021-12-01"),
    latitude = 40.5,
    longitude = -105.5,
    metadata = list(fake_metadata) # Nested list column
  )

  # 2. Run wos_format
  result <- wos_format(
    x = input_data,
    observer = "Test User",
    district = "Pinedale Region",
    survey_type = "Composition"
  )

  # 3. Validation
  expect_equal(nrow(result), 1)

  # Check Logic: Male Aggregation (sub + adult + other)
  expect_equal(result$ma_adult_qty, 4)

  # Check Logic: Column Renaming & Mapping
  expect_equal(result$ma_year_qty, 1)    # juvenile_males -> ma_year_qty
  expect_equal(result$fe_adult_qty, 3)   # females (parent) -> fe_adult_qty
  expect_equal(result$un_juv_qty, 2)     # youngs (parent) -> un_juv_qty
})

test_that("wos_format replaces NAs with 0", {

  fake_metadata_na <- tibble::tibble(
    juvenile_males = NA_integer_,
    sub_males = NA_integer_,
    adult_males = NA_integer_,
    other_males = NA_integer_
  )

  input_data_na <- tibble::tibble(
    species = "Mule Deer",
    total = 5,
    males = NA_integer_, # Top level NA
    females = 5,
    youngs = NA_integer_,
    unclass = NA_integer_,
    date = as.Date("2021-12-01"),
    latitude = 40.0,
    longitude = -105.0,
    metadata = list(fake_metadata_na)
  )

  result <- wos_format(
    x = input_data_na,
    observer = "Test User",
    district = "Pinedale Region",
    survey_type = "Composition"
  )

  # Check that NAs were converted to 0
  expect_equal(result$ma_year_qty, 0) # from metadata NA
  expect_equal(result$un_juv_qty, 0)  # from parent NA

  # Check calculation handling of 0s
  expect_equal(result$ma_adult_qty, 0)
})

test_that("wos_format filters out rows with total = 0", {

  input_zero <- tibble::tibble(
    species = "Mule Deer",
    total = 0,
    date = as.Date("2021-12-01"),
    # Metadata structure doesn't matter here as it gets filtered out
    metadata = list(tibble::tibble(juvenile_males = 0))
  )

  result <- wos_format(
    x = input_zero,
    observer = "Test User",
    district = "Pinedale Region",
    survey_type = "Composition"
  )

  expect_equal(nrow(result), 0)
})

test_that("wos_format errors on unsupported species", {

  input_elk <- tibble::tibble(
    species = "Elk",
    total = 10,
    metadata = list(tibble::tibble(adult_bulls = 1))
  )

  expect_error(
    wos_format(
      x = input_elk,
      observer = "Test User",
      district = "Pinedale Region",
      survey_type = "Composition"
    ),
    "Species .* not currently supported"
  )
})
