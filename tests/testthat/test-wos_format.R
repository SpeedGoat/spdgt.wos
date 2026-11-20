test_that("target species males split into adults and yearlings", {
  out <- fmt(make_entry())

  expect_equal(nrow(out), 1)
  expect_equal(out$ma_adult_qty, 4L)
  expect_equal(out$ma_year_qty, 1L)
  expect_equal(out$fe_adult_qty, 3L)
  expect_equal(out$un_juv_qty, 2L)
  expect_equal(out$un_unk_qty, 0L)
  expect_equal(out$observer_activity, 2L)
  expect_equal(out$district, 2L)
  expect_equal(out$taxon, "Mule Deer")
  expect_equal(out$datum, "WGS 84")
  expect_equal(c(out$obs_year, out$obs_month, out$obs_day), c(2021L, 12L, 1L))
})

test_that("output columns and types match wos_template", {
  out <- fmt(make_entry())
  expect_named(out, names(wos_template))
  expect_identical(
    vapply(out, \(v) class(v)[1], ""),
    vapply(wos_template, \(v) class(v)[1], "")
  )
})

test_that("incidentals are kept whatever shape their mappings take", {
  shapes <- list(
    "no mappings column" = NULL,
    "empty mappings" = tibble::tibble(),
    "NA counts" = tibble::tibble(sub_males = NA_integer_)
  )
  for (shape in names(shapes)) {
    x <- dplyr::bind_rows(
      make_entry(),
      make_entry("Elk", FALSE, total = 4, males = 1, females = 3, youngs = 0,
                 mappings = shapes[[shape]])
    )
    out <- fmt(x)
    elk <- out[out$taxon == "Elk", ]
    expect_equal(nrow(elk), 1, info = shape)
    expect_equal(elk$ma_adult_qty, 1L, info = shape)
    expect_equal(elk$ma_year_qty, 0L, info = shape)
    expect_equal(elk$observer_activity, 1L, info = shape)
  }
})

test_that("incidental males are all reported as adults", {
  out <- fmt(make_entry("Moose", FALSE, total = 6, males = 3, females = 3,
                        youngs = 0))
  expect_equal(out$ma_adult_qty, 3L)
  expect_equal(out$ma_year_qty, 0L)
})

test_that("target species without a male split reports all males as adults", {
  out <- fmt(make_entry(mappings = NULL))
  expect_equal(out$ma_adult_qty, 5L)
  expect_equal(out$ma_year_qty, 0L)
})

test_that("missing counts become zeros and unclassified fill the total", {
  out <- fmt(make_entry(total = 5, males = NA, females = NA, youngs = NA,
                        unclass = NA,
                        mappings = tibble::tibble(adult_males = 2)))
  expect_equal(out$fe_adult_qty, 0L)
  expect_equal(out$ma_adult_qty, 2L)
  expect_equal(out$un_unk_qty, 5L)
})

test_that("sightability totals are reported as unclassified", {
  out <- fmt(
    make_entry(total = 12, males = NA, females = NA, youngs = NA,
               unclass = NA, mappings = NULL),
    "Sightability"
  )
  expect_equal(out$un_unk_qty, 12L)
  expect_equal(out$observer_activity, 9L)
})

test_that("observations with missing or zero totals are dropped", {
  x <- dplyr::bind_rows(make_entry(), make_entry(total = NA),
                        make_entry(total = 0))
  expect_equal(nrow(fmt(x)), 1)
})

test_that("nothing to format returns the empty template with a warning", {
  expect_warning(out <- fmt(make_entry()[0, ]), "Empty dataset")
  expect_identical(out, wos_template)

  expect_warning(out <- fmt(make_entry(total = NA)), "No animals")
  expect_identical(out, wos_template)

  expect_warning(out <- fmt(iris), "Missing column")
  expect_identical(out, wos_template)
})

test_that("classified counts above the total warn and are kept", {
  expect_warning(
    out <- fmt(make_entry(total = 5, males = 5, females = 3, youngs = 2)),
    "more animals than"
  )
  expect_equal(out$fe_adult_qty, 3L)
})

test_that("several sets of classification counts abort", {
  x <- make_entry(mappings = tibble::tibble(sub_males = c(1, 2)))
  expect_error(fmt(x), "more than one set")
})

test_that("arguments are validated", {
  x <- make_entry()
  expect_error(wos_format(list(), "Jane Doe", "Cody Region", "Composition"),
               "must be a data frame")
  expect_error(wos_format(x, "Jane", "Cody Region", "Composition"),
               "Invalid .*observer")
  expect_error(wos_format(x, "Jane Doe", "Mars", "Composition"),
               "District .* not found")
  expect_error(wos_format(x, "Jane Doe", "Cody Region", "Trend"),
               "Survey type .* not found")
})
