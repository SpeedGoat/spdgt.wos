test_that("get_template returns correct template for known species", {
  expect_identical(get_template("Mule Deer"), wos_md_template)
})

test_that("get_template errors for unknown species", {
  expect_error(
    get_template("Unicorn"),
    "Species .* not currently supported"
  )
})

test_that("check_string_input validates correctly", {
  # We test the helper directly to ensure it catches edge cases
  expect_error(check_string_input(123, "arg"), "must be a single character string")
  expect_error(check_string_input(c("a", "b"), "arg"), "must be a single character string")
  expect_silent(check_string_input("valid", "arg"))
})
