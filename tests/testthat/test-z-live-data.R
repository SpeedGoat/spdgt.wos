test_that("the whole pipeline works with real data", {

  skip_no_auth()
  tf <- tempfile(fileext = ".xlsx")

  # 1. Test comp survey with incidental observations
  moose_comp <- suppressMessages(wos_export(
    species = "Moose",
    survey_type = "Composition",
    analysis_unit = "Snowy Range - Sierra Madre 545",
    bio_year = 2024,
    observer = "Jane Doe",
    district = "Laramie Region",
    out_file = tf
  ))

  expect_gt(
    length(unique(moose_comp$taxon)),
    1,
    "Incidental observations missing from wos_export output (comp)"
  )

  comp_counts <- dplyr::select(
    moose_comp,
    dplyr::all_of(
      c("ma_adult_qty", "ma_year_qty", "fe_adult_qty", "un_juv_qty")
    )
  )

  expect_all_true(colSums(comp_counts) > 0)

  expect_all_true(rowSums(comp_counts) > 0)

  expect_contains(colnames(moose_comp), colnames(wos_template))

  expect_true(
    file.exists(tf),
    "Output file not created by wos_export (comp)"
  )

  try(unlink(tf), silent = TRUE)

  # 2. Test sightability survey
  md_sight <- suppressMessages(wos_export(
    species = "Mule Deer",
    survey_type = "Sightability",
    analysis_unit = "Uinta 423",
    bio_year = 2025,
    observer = "Jane Doe",
    district = "Green River Region",
    out_file = tf
  ))

  sight_counts <- dplyr::select(md_sight, dplyr::all_of(c("un_unk_qty")))

  expect_all_true(colSums(sight_counts) > 0)

  expect_all_true(rowSums(sight_counts) > 0)

  expect_contains(colnames(md_sight), colnames(wos_template))

  expect_true(
    file.exists(tf),
    "Output file not created by wos_export (sightability)"
  )

  try(unlink(tf), silent = TRUE)

})
