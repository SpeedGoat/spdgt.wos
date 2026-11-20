#' Format observations for Wildlife Observation System (WOS) import
#'
#' @param x data frame of observations as returned by `wos_read()`
#' @param observer the name of the observer in "First Last" format
#' @param district the district name as found in the `districts` data set
#' @param survey_type the type of survey conducted; must match one of the
#' survey types in the `survey_types` data set
#'
#' @details
#' Observations with no animals (`total` of zero or missing) are dropped. Every
#' other observation becomes one WOS row, whether it is of the survey's target
#' species or an incidental observation of another species.
#'
#' Target species observations are given the activity code of the survey type
#' (see `survey_types`) and have their males split into adults
#' (`ma_adult_qty`, the sum of sub-adult, adult and other males) and yearlings
#' (`ma_year_qty`) from the classification `mappings`. Incidental observations
#' are coded as casual observations (activity code 1) and report all males in
#' `ma_adult_qty`. When an observation has no male breakdown, all of its males
#' are reported in `ma_adult_qty`.
#'
#' Animals in `total` that are not classified as male, female or young are
#' reported in `un_unk_qty`, so each row's counts add up to its total. A row
#' whose classified counts exceed its total is kept as recorded, with a
#' warning.
#'
#' @returns A tibble with the columns of `wos_template`, one row per
#' observation. When there is nothing to format a zero-row `wos_template` is
#' returned with a warning.
#' @export
wos_format <- function(x, observer, district, survey_type) {

  if (!is.data.frame(x)) {
    cli::cli_abort(
      "{.arg x} must be a data frame, not {.obj_type_friendly {x}}."
    )
  }
  check_observer(observer)
  check_district(district)
  check_survey_type(survey_type)

  template <- pkg_data("wos_template")

  req_cols <- c(
    "total", "males", "females", "youngs", "unclass", "metadata", "species",
    "date", "is_target_species"
  )

  if (!nrow(x)) {
    cli::cli_warn("Empty dataset provided, returning empty template.")
    return(template)
  }

  m_cols <- setdiff(req_cols, colnames(x))
  if (length(m_cols)) {
    cli::cli_warn(
      "Missing column{?s} {.field {m_cols}}, returning empty template."
    )
    return(template)
  }

  x <- dplyr::filter(x, .data$total > 0)

  if (!nrow(x)) {
    cli::cli_warn("No animals detected, returning empty template.")
    return(template)
  }

  dstrct <- as.integer(pkg_data("districts")[[district]])

  act <- pkg_data("survey_types") |>
    dplyr::filter(.data$survey_type == .env$survey_type) |>
    dplyr::pull("activity_code") |>
    as.integer()

  male_parts <- c("sub_males", "adult_males", "other_males")
  count_cols <- c(
    "total", "males", "females", "youngs", "unclass", "juvenile_males",
    male_parts
  )

  rename_cols <- c(
    ma_year_qty = "juvenile_males",
    fe_adult_qty = "females",
    un_juv_qty = "youngs",
    un_unk_qty = "unclass"
  )

  flat <- unnest_counts(x)

  # Columns that never appeared in the data are still needed below
  for (col in setdiff(c("juvenile_males", male_parts), colnames(flat))) {
    flat[[col]] <- NA_integer_
  }

  out <- flat |>
    dplyr::mutate(
      dplyr::across(dplyr::all_of(count_cols), as.integer),
      is_target_species = .data$is_target_species %in% TRUE,
      # Adult males come from the classification only where it has any male
      # breakdown; otherwise every male is reported as an adult.
      has_male_split = !is.na(.data$sub_males) | !is.na(.data$adult_males) |
        !is.na(.data$other_males) | !is.na(.data$juvenile_males),
      dplyr::across(dplyr::all_of(count_cols), \(v) tidyr::replace_na(v, 0L)),
      ma_adult_qty = dplyr::if_else(
        .data$is_target_species & .data$has_male_split,
        .data$sub_males + .data$adult_males + .data$other_males,
        .data$males
      ),
      juvenile_males = dplyr::if_else(
        .data$is_target_species & .data$has_male_split,
        .data$juvenile_males,
        0L
      ),
      classified = .data$males + .data$females + .data$youngs,
      unclass = pmax(.data$unclass, .data$total - .data$classified),
      observer = trimws(.env$observer),
      district = .env$dstrct,
      date = as.Date(.data$date),
      obs_month = as.integer(format(.data$date, "%m")),
      obs_year = as.integer(format(.data$date, "%Y")),
      obs_day = as.integer(format(.data$date, "%d")),
      taxon = .data$species,
      observer_activity = dplyr::if_else(.data$is_target_species, .env$act, 1L),
      datum = "WGS 84"
    )

  over <- out$classified + out$unclass > out$total
  if (any(over)) {
    cli::cli_warn(c(
      "{sum(over)} observation{?s} classif{?ies/y} more animals than
      {?its/their} total.",
      "i" = "Counts are exported as recorded; check them in SpeedGoat."
    ))
  }

  out <- out |>
    dplyr::rename(dplyr::any_of(rename_cols)) |>
    dplyr::select(dplyr::any_of(colnames(template)))

  dplyr::bind_rows(template, out)

}

# One row per observation, with the classification mappings as columns.
#
# `metadata` is a list column of one-row tibbles and `mappings`, inside it, a
# list column of the classification counts. Incidental observations often have
# no mappings at all, so both unnests keep empty rows: tidyr's default drops
# them, which silently removed every incidental from the export.
unnest_counts <- function(x) {
  x$.row_id <- seq_len(nrow(x))
  x$metadata <- lapply(x$metadata, \(m) if (is.null(m)) tibble::tibble() else m)

  # Columns of the same name in the observation and its metadata would be
  # duplicated by unnest(); the observation's own values win.
  out <- tidyr::unnest(
    x, "metadata", keep_empty = TRUE, names_repair = "minimal"
  )
  out <- out[, !duplicated(names(out)), drop = FALSE]

  if ("mappings" %in% colnames(out)) {
    out <- tidyr::unnest(
      out, "mappings", keep_empty = TRUE, names_repair = "minimal"
    )
    out <- out[, !duplicated(names(out)), drop = FALSE]
  }

  if (anyDuplicated(out$.row_id)) {
    cli::cli_abort(c(
      "Some observations have more than one set of classification counts.",
      "x" = "Exporting them would count the same animals more than once."
    ))
  }

  out$.row_id <- NULL
  out
}
