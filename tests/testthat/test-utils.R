test_that("check_string_input validates correctly", {
  # We test the helper directly to ensure it catches edge cases
  expect_error(check_string_input(123, "arg"), "must be a single character string")
  expect_error(check_string_input(c("a", "b"), "arg"), "must be a single character string")
  expect_silent(check_string_input("valid", "arg"))
})
