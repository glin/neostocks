context("utils")

test_that("as_datetime converts time strings", {
  time <- as_datetime("2018-07-01T17:30:00Z")
  expected <- as.POSIXct(1530466200, origin = "1970-01-01", tz = TZ_NST)
  expect_equal(time, expected)
})

test_that("as_date converts date strings", {
  date <- as_date("2018-07-03")
  expected <- as.Date("2018-07-03", tz = TZ_NST)
  expect_equal(date, expected)
})

test_that("to_iso_string converts datetimes", {
  time <- as_datetime("2018-07-01T17:30:00Z")
  str <- to_iso_string(time)
  expect_equal(str, "2018-07-01T17:30:00Z")
})
