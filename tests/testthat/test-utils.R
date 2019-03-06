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

test_that("as_json defaults", {
  expect_equal(as.character(as_json("auto unboxed?")), '"auto unboxed?"')
  expect_equal(as.character(as_json(NULL)), "null")
  expect_equal(as.character(as_json(NA)), "null")

  df <- data.frame(
    a = c(1, 2),
    b = as_datetime(c("2018-07-04", "2018-08-04"))
  )
  expected <- '[{"a":1,"b":"2018-07-04T07:00:00Z"},{"a":2,"b":"2018-08-04T07:00:00Z"}]'
  expect_equal(as.character(as_json(df)), expected)
})
