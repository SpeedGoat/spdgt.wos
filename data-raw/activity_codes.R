activity_codes <- tibble::tibble(
  activity_code = 1:14,
  activity_descr = c(
    "OA1 - Casual observation",
    "OA2 - Classification counts",
    "OA3 - Aerial Trend Counts",
    "OA4 - Ground Trend Counts",
    "OA5 - Live Trapping Operation - Animal",
    "OA6 - Permanent Check Station",
    "OA7 - Field Check Station",
    "OA8 - Other Check Station",
    "OA9 - Census/Survey",
    "OA10 - Mortality Transects",
    "OA11 - Nesting/Production Survey",
    "OA12 - Marked Animal",
    "OA13 - Damage Control",
    "OA14 - Seasonal Range Survey"
  )
)
usethis::use_data(activity_codes, overwrite = TRUE)
