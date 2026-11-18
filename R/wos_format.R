#' Format observations for entry in WOS
#'
#' @param x data frame of observations as returned by `wos_read()`
#' @param observer the name of the observer in "First Last" format
#' @param district the district name as found in the `districts` data set
#' @param survey_type the type of survey conducted; must match one of the
#' survey types in the `survey_types` data set
#'
#' @returns A data frame formatted for WOS import
#' @export
wos_format <- function(x, observer, district, survey_type) {

  count_cols <- c(
    "total", "males", "females", "youngs", "unclass", "juvenile_males",
    "sub_males", "adult_males", "other_males"
  )

  req_cols <- c(
    count_cols[1:5], "metadata", "species", "date", "is_target_species"
  )

  if (!nrow(x)) {
    cli::cli_warn("Empty dataset provided, returning empty template.")
    return(wos_template)
  }

  m_cols <- setdiff(req_cols, colnames(x))
  if (length(m_cols)) {
    cli::cli_warn(
      "Missing column{?s} {.field {m_cols}}, returning empty template."
    )
    return(wos_template)
  }

  # Test for dataset with no animals detected
  if (sum(x$total > 0) == 0) {
    cli::cli_warn("No animals detected, returning empty template.")
    return(wos_template)
  }

  dstrct <- districts[[district]]

  # Get activity code from survey type
  act <- survey_types |>
    dplyr::filter(.data$survey_type == .env$survey_type) |>
    dplyr::pull(.data$activity_code)

  rename_cols <- c(
    ma_year_qty = "juvenile_males",
    fe_adult_qty = "females",
    un_juv_qty = "youngs",
    un_unk_qty = "unclass"
  )

  out <- x |>
    dplyr::filter(.data$total > 0) |>
    tidyr::unnest("metadata") |>
    tidyr::unnest(dplyr::any_of("mappings")) |>
    dplyr::mutate(
      dplyr::across(
        dplyr::any_of(count_cols),
        \(x) tidyr::replace_na(as.integer(x), 0)
      ),
      observer = .env$observer,
      district = as.numeric(.env$dstrct),
      date = as.Date(.data$date),
      obs_month = as.numeric(format(.data$date, "%m")),
      obs_year = as.numeric(format(.data$date, "%Y")),
      obs_day = as.numeric(format(.data$date, "%d")),
      taxon = .data$species,
      ma_adult_qty = rowSums(
        dplyr::pick(dplyr::any_of(c("sub_males", "adult_males", "other_males")))
      ),
      unclass = pmax(
        .data$unclass,
        .data$total - .data$males - .data$females - .data$youngs
      ),
      observer_activity = dplyr::if_else(.data$is_target_species, .env$act, 1),
      datum = "WGS 84"
    ) |>
    dplyr::rename(dplyr::any_of(rename_cols)) |>
    dplyr::select(dplyr::any_of(colnames(wos_template)))

  dplyr::bind_rows(wos_template, out)

}
