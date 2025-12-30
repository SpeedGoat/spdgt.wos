# --- Setup Mocks ---
survey_types <- tibble::tibble(
  species = "Mule Deer",
  survey_type = c("Composition", "Sightability"),
  activity_code = c(2, 9)
)
districts <- list("Pinedale Region" = 5)

test_that("wos_format: Classification (Act 2) replaces NAs with 0s", {

  # 1. Innermost Data (The Counts)
  fake_counts <- tibble::tibble(
    does = NA_integer_,
    fawns = NA_integer_,
    juvenile_males = NA_integer_,
    sub_males = NA_integer_,
    adult_males = 2,
    other_males = NA_integer_
  )

  # 2. Middle Layer (The Metadata Tibble)
  #    This mimics md_raw$metadata[[1]].
  #    We make 'mappings' a list-column to satisfy unnest().
  fake_metadata_wrapper <- tibble::tibble(
    mappings = list(fake_counts),
    notes = NA
  )

  # 3. Outer Layer (The Input Data)
  input_data <- tibble::tibble(
    species = "Mule Deer",
    total = 5,
    males = 2,
    females = NA_integer_,
    youngs = NA_integer_,
    unclass = 0,
    date = as.Date("2021-12-01"),
    latitude = 40.5,
    longitude = -105.5,
    # metadata is a list-column containing the wrapper tibble
    metadata = list(fake_metadata_wrapper)
  )

  result <- wos_format(
    input_data,
    "Test User",
    "Pinedale Region",
    "Composition"
  )

  # CHECK: NAs became 0s
  expect_equal(result$fe_adult_qty, 0) # females -> 0
  expect_equal(result$ma_year_qty, 0)  # juvenile_males -> 0
  expect_equal(result$ma_adult_qty, 2) # Calculation handles 0s correctly
})

test_that("wos_format: Sightability (Act 9) PRESERVES NAs", {

  # 1. Innermost Data
  fake_counts <- tibble::tibble(
    sub_males = NA_integer_
  )

  # 2. Middle Layer
  fake_metadata_wrapper <- tibble::tibble(
    mappings = list(fake_counts),
    notes = NA
  )

  # 3. Outer Layer
  input_data <- tibble::tibble(
    species = "Mule Deer",
    total = 50,
    males = NA_integer_,
    females = 0, # Explicit 0 in raw data
    youngs = NA_integer_,
    unclass = 50,
    date = as.Date("2021-12-01"),
    latitude = 40.5,
    longitude = -105.5,
    metadata = list(fake_metadata_wrapper)
  )

  result <- wos_format(input_data, "Test User", "Pinedale Region", "Sightability")

  # CHECK 1: NAs remain NAs
  expect_true(is.na(result$un_juv_qty))

  # CHECK 2: Explicit 0s are forced to NA (The safety check)
  expect_true(is.na(result$fe_adult_qty))

  # CHECK 3: Calculated columns are NA
  expect_true(is.na(result$ma_adult_qty))
})
