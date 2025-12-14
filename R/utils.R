TZ_NST <- "America/Los_Angeles"

as_datetime <- function(x, tz = TZ_NST) {
  suppressMessages(lubridate::as_datetime(x, tz = tz))
}

as_date <- function(x, tz = TZ_NST) {
  # Note: as.Date ignores tz for character strings
  as.Date(x, tz = tz)
}

# Get the date of an existing date-time object. Use this over as_date() for
# date-time objects as date() will be much faster.
date <- function(x) {
  lubridate::date(x)
}

floor_date <- function(x, unit = "day") {
  lubridate::floor_date(x, unit = unit)
}

to_iso_string <- function(time, tz = "UTC") {
  strftime(time, tz = tz, format = "%Y-%m-%dT%H:%M:%SZ")
}

as_json <- function(x, ...) {
  UseMethod("as_json")
}

#' @export
as_json.default <- function(x, dataframe = "rows", auto_unbox = TRUE, null = "null",
                            na = "null", UTC = TRUE, POSIXt = "ISO8601", ...) {
  jsonlite::toJSON(x, dataframe = dataframe, auto_unbox = auto_unbox, null = null,
                   na = na, UTC = UTC, POSIXt = POSIXt, ...)
}

log_info <- function(...) {
  message(Sys.time(), " ", ...)
}
