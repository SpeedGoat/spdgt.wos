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

  # Will require updating if incidental observations added later
  # Maybe call the API or use spdgt.core::lkup_survey_types()
  sp <- unique(x$species)

  dstrct <- districts[[district]]

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

  tmp <- x |>
    dplyr::filter(.data$total > 0)

  if (nrow(tmp) == 0) {
    return(wos_md_template)
  }

  out <- tmp |>
    tidyr::unnest("metadata") |>
    tidyr::unnest(dplyr::any_of("mappings")) |>
    dplyr::mutate(
      dplyr::across(
        dplyr::any_of(
          c("total", "males", "females", "youngs", "unclass", "juvenile_males",
            "sub_males", "adult_males", "other_males")
        ),
        \(x) as.integer(x)
      )
    ) |>
    dplyr::mutate(
      dplyr::across(
        dplyr::any_of(
          c("total", "males", "females", "youngs", "unclass", "juvenile_males",
            "sub_males", "adult_males", "other_males")
        ),
        \(x) if (isTRUE(act_code == 2)) tidyr::replace_na(x, replace = 0) else x
      ),
      dplyr::across(
        dplyr::any_of(
          c("total", "males", "females", "youngs", "unclass", "juvenile_males",
            "sub_males", "adult_males", "other_males")
        ),
        \(x) if (isTRUE(act_code == 2)) x else NA_integer_
      )
    ) |>
    dplyr::mutate(
      observer = observer,
      district = as.numeric(district),
      date = as.Date(.data$date),
      obs_month = as.numeric(format(.data$date, "%m")),
      obs_year = as.numeric(format(.data$date, "%Y")),
      obs_day = as.numeric(format(.data$date, "%d")),
      taxon = .data$species,
      ma_adult_qty = if (isTRUE(act_code == 2)) {
        rowSums(
          dplyr::pick(
            dplyr::any_of(c("sub_males", "adult_males", "other_males"))
          ),
          na.rm = TRUE
        )
      } else {
        NA_real_
      },
      ma_est_cnt_flag = FALSE,
      fe_est_cnt_flag = FALSE,
      un_est_cnt_flag = FALSE,
      observer_activity = act_code,
      datum = "WGS84"
    ) |>
    dplyr::rename_with(
      .fn = ~ c(
        "juvenile_males" = "ma_year_qty",
        "females"        = "fe_adult_qty",
        "youngs"         = "un_juv_qty",
        "unclass"        = "un_unk_qty",
        "latitude"       = "latitude",
        "longitude"      = "longitude"
      )[.],
      .cols = dplyr::any_of(c(
        "juvenile_males",
        "females",
        "youngs",
        "unclass",
        "latitude",
        "longitude"
      ))
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
    out
  )
}
