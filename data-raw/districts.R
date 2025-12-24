## code to prepare `districts` dataset goes here
districts <- stats::setNames(
  c(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 33, 35),
  c(
    "Cheyenne Headquarters", "Pinedale Region", "Cody Region",
    "Sheridan Region", "Green River Region", "Laramie Region", "Lander Region",
    "Casper Region", "Nongame Program", "Migratory Game Bird Program",
    "Jackson Region", "Chapter 33", "Jackson Hole Nature Mapping"
  )
)

usethis::use_data(districts, overwrite = TRUE)
