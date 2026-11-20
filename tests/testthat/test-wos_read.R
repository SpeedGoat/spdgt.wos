test_that("wos_read keeps every observation on the species' survey", {
  entries <- dplyr::bind_rows(
    make_entry(survey_type_id = 7L),
    make_entry("Elk", FALSE, survey_type_id = 7L),
    make_entry("Elk", TRUE, survey_type_id = 9L)
  )
  m_lkup <- mockery::mock(tibble::tibble(id = 7L))
  m_read <- mockery::mock(entries)
  mockery::stub(wos_read, "spdgt.core::lkup_survey_type", m_lkup)
  mockery::stub(wos_read, "spdgt.sight::sight_read_entries", m_read)

  out <- wos_read("Mule Deer", "Composition", "Unit 1", 2021)

  expect_equal(out$species, c("Mule Deer", "Elk"))
  expect_equal(
    mockery::mock_args(m_lkup)[[1]],
    list(species_name = "Mule Deer", survey_type_name = "Composition")
  )
  read_args <- mockery::mock_args(m_read)[[1]]
  expect_equal(read_args$survey_type, "Composition")
  expect_equal(read_args$analysis_unit, "Unit 1")
  expect_equal(read_args$bio_year, 2021)
  expect_equal(read_args$pages, list("omit" = 1))
  expect_null(read_args$species)
  expect_null(read_args$is_target_species)
})

test_that("wos_read aborts when the species has no such survey type", {
  mockery::stub(wos_read, "spdgt.core::lkup_survey_type",
                tibble::tibble(id = integer()))
  m_read <- mockery::mock()
  mockery::stub(wos_read, "spdgt.sight::sight_read_entries", m_read)

  expect_error(wos_read("Mule Deer", "Composition", "Unit 1", 2021),
               "No .* survey type found")
  mockery::expect_called(m_read, 0)
})

test_that("wos_read validates its arguments", {
  expect_error(wos_read(NA_character_, "Composition", "U", 2021), "species")
  expect_error(wos_read("Mule Deer", "Composition", "", 2021), "analysis_unit")
  expect_error(wos_read("Mule Deer", "Composition", "U", 2021.5), "bio_year")
})
