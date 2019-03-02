TZ_NST <- "America/Los_Angeles"

as_datetime <- function(x, tz = TZ_NST) {
  suppressMessages(lubridate::as_datetime(x, tz = tz))
}

as_date <- function(x, tz = TZ_NST) {
  as.Date(x, tz = tz)
}

to_iso_string <- function(time, tz = "UTC") {
  strftime(time, tz = tz, format = "%Y-%m-%dT%H:%M:%SZ")
}
