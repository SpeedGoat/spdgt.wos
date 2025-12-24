#' Format observations for entry in WOS
#'
#' @param x data frame of observations as returned by `wos_read()`
#' @param observer the name of the observer in "First Last" format
#' @param district the district name as found in the `districts` data set
#' @param survey_type the type of survey conducted; must match one of the
#' survey types in the `survey_types` data set for the species in `x`
#'
#' @returns A data frame formatted for WOS import
#' @export
wos_format <- function(x, observer, district, survey_type) {

  # Get species from data
  sp <- unique(x$species)

  # Get district
  dstrct <- districts[[district]]

  # Get activity code from species and survey type
  act <- survey_types |>
    dplyr::filter(
      .data$species == sp,
      .data$survey_type == !!survey_type
    ) |>
    dplyr::pull(.data$activity_code)

  switch(
    sp,
    "Mule Deer" = wos_format_md(x, observer, dstrct, act),
    {
      cli::cli_abort(
        "Species {.val {sp}} not currently supported for WOS formatting."
      )
    }
  )

}

wos_format_md <- function(x, observer, district, act_code) {

  # 1. Filter empty observations
  # CRITICAL: We break the pipe here to assign to 'tmp'
  tmp <- x |>
    dplyr::filter(.data$total > 0)

  # 2. Safety Check: If filtering removed all rows, return empty template
  # This protects the subsequent 'unnest' and 'mutate' steps from failing
  if (nrow(tmp) == 0) {
    return(wos_md_template)
  }

  # 3. Format
  tmp <- tmp |>
    # Fix Warning: Use string "metadata", not .data$metadata
    tidyr::unnest("metadata") |>
    dplyr::mutate(
      dplyr::across(
        dplyr::all_of(
          c("total", "males", "females", "youngs", "unclass", "juvenile_males",
            "sub_males", "adult_males", "other_males")
        ),
        as.integer
      )
    ) |>
    tidyr::replace_na(
      list(
        total = 0,
        males = 0,
        females = 0,
        youngs = 0,
        unclass = 0,
        juvenile_males = 0,
        sub_males = 0,
        adult_males = 0,
        other_males = 0
      )
    ) |>
    dplyr::mutate(
      observer = observer,
      district = as.numeric(district),
      date = as.Date(.data$date),
      obs_month = as.numeric(format(.data$date, "%m")),
      obs_year = as.numeric(format(.data$date, "%Y")),
      obs_day = as.numeric(format(.data$date, "%d")),
      taxon = unique(.data$species),
      # .data$ is still allowed/encouraged in mutate() for data masking
      ma_adult_qty = .data$sub_males + .data$adult_males + .data$other_males,
      ma_est_cnt_flag = FALSE,
      fe_est_cnt_flag = FALSE,
      un_est_cnt_flag = FALSE,
      observer_activity = act_code,
      datum = "WGS84"
    ) |>
    # Fix Warning: Remove .data$ from rename(). Use strings or symbols.
    dplyr::rename(
      ma_year_qty = "juvenile_males",
      fe_adult_qty = "females",
      un_juv_qty = "youngs",
      un_unk_qty = "unclass",
      latitude = "latitude",
      longitude = "longitude"
    ) |>
    dplyr::select(
      dplyr::any_of(
        c("observer", "district", "obs_month", "obs_year", "obs_day", "taxon",
          "ma_adult_qty", "ma_year_qty", "ma_est_cnt_flag", "fe_adult_qty",
          "fe_est_cnt_flag", "un_juv_qty", "un_unk_qty", "un_est_cnt_flag",
          "observer_activity", "latitude", "longitude", "datum")
      )
    )

  dplyr::bind_rows(
    wos_md_template,
    tmp
  )
}
