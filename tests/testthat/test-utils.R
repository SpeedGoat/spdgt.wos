test_that("check_string_input validates correctly", {
  expect_error(check_string_input(123, "arg"), "single, non-empty character")
  expect_error(check_string_input(c("a", "b"), "arg"), "single")
  expect_error(check_string_input(NA_character_, "arg"), "single")
  expect_error(check_string_input("", "arg"), "non-empty")
  expect_silent(check_string_input("valid", "arg"))
})

test_that("check_bio_year accepts only one whole year", {
  expect_silent(check_bio_year(2021))
  expect_silent(check_bio_year(2021L))
  expect_error(check_bio_year("2021"), "single numeric year")
  expect_error(check_bio_year(c(2020, 2021)), "single numeric year")
  expect_error(check_bio_year(NA_real_), "single numeric year")
  expect_error(check_bio_year(2021.5), "single numeric year")
})

test_that("check_observer wants First Last", {
  expect_silent(check_observer("Mary-Anne O'Connor"))
  expect_silent(check_observer(" Jane  Doe "))
  expect_error(check_observer("Jane"), "Invalid")
  expect_error(check_observer("Jane Q Doe"), "Invalid")
})

test_that("pkg_data reaches lazy data without the package attached", {
  expect_identical(pkg_data("districts"), spdgt.wos::districts)
  expect_identical(pkg_data("wos_template"), spdgt.wos::wos_template)
})
