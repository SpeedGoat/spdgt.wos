test_that("districts dataset is valid", {
  # 1. Structure Check
  expect_type(districts, "double")
  expect_named(districts)

  # 2. Content Check (Spot check critical values)
  expect_true("Pinedale Region" %in% names(districts))
  expect_true("Cheyenne Headquarters" %in% names(districts))

  # 3. Uniqueness Check (Districts codes should be unique)
  expect_equal(anyDuplicated(districts), 0)
})

test_that("survey_types dataset is valid", {
  # 1. Schema Check
  expect_s3_class(survey_types, "data.frame")
  expect_true(all(c("species", "survey_type", "activity_code") %in% names(survey_types)))

  # 2. Type Check
  expect_type(survey_types$species, "character")
  expect_type(survey_types$survey_type, "character")
  # Activity code might be integer or numeric, check based on your data creation
  expect_true(is.numeric(survey_types$activity_code))

  # 3. Logic Check (No duplicate species+survey_type combos)
  dupes <- survey_types |>
    dplyr::count(species, survey_type) |>
    dplyr::filter(n > 1)

  expect_equal(nrow(dupes), 0)
})

test_that("wos_md_template is a valid empty template", {
  # 1. It should be empty (0 rows)
  expect_equal(nrow(wos_md_template), 0)

  # 2. It should have the specific columns your format function expects
  expected_cols <- c("observer", "district", "obs_year", "taxon",
                     "ma_adult_qty", "ma_year_qty", "fe_adult_qty")

  expect_true(all(expected_cols %in% names(wos_md_template)))

  # 3. Type Check (Spot check a few critical columns)
  expect_type(wos_md_template$observer, "character")
  expect_type(wos_md_template$district, "integer")
})
