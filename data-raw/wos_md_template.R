## code to prepare `wos_md_template` dataset goes here

wos_md_template <- tibble::tibble(
  observer = character(),         # First Last
  district = integer(),           # e.g. 1
  obs_month = integer(),          # MM
  obs_year = integer(),           # YYYY
  obs_day = integer(),            # DD
  taxon = character(),            # common name
  ma_adult_qty = integer(),       # adult males
  ma_year_qty = integer(),        # yearling males
  ma_juv_qty = integer(),         # juvenile males
  ma_unk_qty = integer(),         # unknown age males
  ma_est_cnt_flag = logical(),    # are quantities an estimate?
  ma_age = numeric(),             # age of male observed
  fe_adult_qty = integer(),       # adult females
  fe_year_qty = integer(),        # yearling females
  fe_juv_qty = integer(),         # juvenile females
  fe_unk_qty = integer(),         # unknown females
  fe_est_cnt_flag = logical(),    # are quantities an estimate?
  fe_age = numeric(),             # age of females observed
  un_adult_qty = integer(),       # unknown adults
  un_year_qty = integer(),        # unknown yearlings
  un_juv_qty = integer(),         # unknown juveniles
  un_unk_qty = integer(),         # unknown unknown quantity
  un_est_cnt_flag = logical(),    # are quantities an estimate?
  un_age = numeric(),             # age of unknown observed
  detection_type = character(),   # visual likely only value needed
  hunt_area = character(),        # optional
  sug_area = character(),         # optional, likely blank
  degree_block = character(),     # non-game bird only, leave blank
  habitat_type = character(),     # leave blank
  mortality_code = character(),   # leave blank
  animal_activity = character(),  # leave blank
  observer_activity = integer(),  # Single value TBD, 2 and 9 likely
  dwelling_feature = character(), # leave blank
  dwell_othr = character(),       # leave blank
  dwell_count = numeric(),        # leave blank
  dwell_est_cnt_flag = logical(), # leave blank
  dwell_perc_active = numeric(),  # leave blank
  dwell_iden = numeric(),         # leave blank
  dwell_note = character(),       # leave blank
  utm_zone = character(),         # leave blank
  utm_easting = numeric(),        # leave blank
  utm_northing = numeric(),       # leave blank
  latitude = numeric(),           # decimal degrees
  longitude = numeric(),          # decimal degrees
  datum = character(),            # WGS 84
  source = character(),           # leave blank
  field_notes = character()       # leave blank
)

usethis::use_data(wos_md_template, overwrite = TRUE)
