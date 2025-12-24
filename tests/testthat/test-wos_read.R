test_that("wos_read passes the correct hardcoded arguments to read_entries", {
  # 1. Create a mock function
  # This fake function just returns "Success" so we know it ran
  m <- mockery::mock("Success")

  # 2. Stub the real function with our mock
  # usage: stub(where_function_is_called, "function_to_mock", mock_object)
  mockery::stub(wos_read, "spdgt.sight::read_entries", m)

  # 3. Call wos_read
  result <- wos_read(
    species = "Mule Deer",
    survey_type = "Composition",
    analysis_unit = "Unit 1",
    bio_year = 2021
  )

  # 4. Verify the results

  # Check 1: Did it call our mock?
  mockery::expect_called(m, 1)

  # Check 2: Get the arguments passed to the mock
  args <- mockery::mock_args(m)[[1]]

  # Check 3: specific arguments
  expect_equal(args$species, "Mule Deer")
  expect_equal(args$survey_type, "Composition")
  expect_equal(args$analysis_unit, "Unit 1")
  expect_equal(args$bio_year, 2021)

  # CRITICAL CHECKS: The hardcoded values
  expect_true(args$is_target_species)
  expect_equal(args$pages, list("omit" = 1))
})
