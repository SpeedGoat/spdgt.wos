## code to prepare `survey_types` dataset goes here
survey_types <- tibble::tibble(
  species = "Mule Deer",
  survey_type = c("Composition", "Sightability"),
  activity_code = c(2, 9)
)
usethis::use_data(survey_types, overwrite = TRUE)
