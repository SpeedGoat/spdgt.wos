skip_no_auth <- function() {
  testthat::skip_on_cran()

  is_auth <- tryCatch(
    spdgt.auth::is_auth(),
    error = function(e) {
      FALSE
    }
  )

  testthat::skip_if_not(
    is_auth,
    "API unavailable or not authenticated"
  )

}
