test_that("wos_read passes the correct hardcoded arguments to read_entries", {

  m_res <- mockery::mock(tibble::tibble())

  mockery::stub(wos_read, "spdgt.sight::sight_read_entries", m_res)

  result <- wos_read(
    species = "Mule Deer",
    survey_type = "Composition",
    analysis_unit = "Unit 1",
    bio_year = 2021
  )

  mockery::expect_called(m_res, 1)

  read_args <- mockery::mock_args(m_res)[[1]]

  expect_equal(read_args$bio_year, 2021)
  expect_equal(read_args$pages, list("omit" = 1))

  expect_false("is_target_species" %in% names(read_args))

})
