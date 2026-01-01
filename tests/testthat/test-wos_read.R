# test_that("wos_read passes the correct hardcoded arguments to read_entries", {
#
#   fake_ids <- list(
#     species_id = 0,
#     survey_type_id = 0,
#     dau_id = 0
#   )
#
#   m_id <- mockery::mock(fake_ids)
#
#   mockery::stub(wos_read, "spdgt.sight:::lookup_by_name", m_id)
#
#   m_res <- mockery::mock(tibble::tibble())
#
#   mockery::stub(wos_read, "spdgt.sight::read_entries_id", m_res)
#
#   result <- wos_read(
#     species = "Mule Deer",
#     survey_type = "Composition",
#     analysis_unit = "Unit 1",
#     bio_year = 2021
#   )
#
#   mockery::expect_called(m_id, 1)
#   mockery::expect_called(m_res, 1)
#
#   id_args <- mockery::mock_args(m_id)[[1]]
#
#   expect_equal(id_args$species, "Mule Deer")
#   expect_equal(id_args$survey_type, "Composition")
#   expect_equal(id_args$analysis_unit, "Unit 1")
#
#   read_args <- mockery::mock_args(m_res)[[1]]
#
#   expect_equal(read_args$bio_year, 2021)
#   expect_equal(read_args$pages, list("omit" = 1))
#
#   # changed by EN - is_target_species should NOT appear
#   expect_false("is_target_species" %in% names(read_args))
#
# })

# test removed because stubbing spdgt.sight:::lookup_by_name wasn't working
