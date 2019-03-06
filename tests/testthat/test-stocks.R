context("stocks")

test_that("calc_market_index", {
  data <- data.table(
    ticker = c("AAVL", "BUZZ", "AAVL", "BUZZ"),
    time = c(1542222222, 1542222222, 1543333333, 1543333333),
    volume = c(100, 200, 300, 400),
    open = c(20, 30, 40, 50),
    curr = c(22, 33, 44, 55)
  )

  index <- calc_market_index(data)
  expected <- data.table(
    time = c(1542222222, 1543333333),
    ticker = c("NEODAQ", "NEODAQ"),
    volume = c(300, 700),
    open = c(50, 90),
    curr = c(55, 99)
  )
  expect_equal(index, expected)
})

test_that("get_ticker_prices", {
  prices_5d <- data.table(
    ticker = c("AAVL", "BUZZ"),
    time = c(1542222222, 1543333333),
    curr = c(22, 33)
  )
  prices_all <- data.table(
    ticker = c("AAVL", "BUZZ"),
    time = c(1544444444, 1545555555),
    curr = c(22, 33)
  )
  peaks <- data.table(
    ticker = c("AAVL", "BUZZ"),
    date = c("2018-10-10", "2018-11-10")
  )

  price_data <- list(
    "5d" = prices_5d,
    all = prices_all,
    peaks = peaks
  )

  expect_null(get_ticker_prices(price_data, "AAVL", "invalid-period"))
  expect_null(get_ticker_prices(price_data, "invalid-ticker", "5d"))

  AAVL_5d <- get_ticker_prices(price_data, "AAVL", "5d")
  expect_equal(AAVL_5d$prices, prices_5d[ticker == "AAVL", list(time, curr)])
  expect_equal(attr(AAVL_5d, "ticker"), "AAVL")
  expect_equal(attr(AAVL_5d, "period"), "5d")

  BUZZ_all <- get_ticker_prices(price_data, "BUZZ", "ALL")
  expect_equal(BUZZ_all$prices, prices_all[ticker == "BUZZ", list(time, curr)])
  expect_equal(BUZZ_all$peaks, peaks[ticker == "BUZZ", date])
  expect_equal(attr(BUZZ_all, "ticker"), "BUZZ")
  expect_equal(attr(BUZZ_all, "period"), "all")
})

test_that("as_json.ticker_prices", {
  prices <- data.table(
    ticker = c("AAVL", "AAVL"),
    time = as_datetime(c(1542222222, 1543333333)),
    curr = c(22, 33)
  )
  peaks <- data.table(
    ticker = c("AAVL", "AAVL"),
    date = c("2018-10-10", "2018-11-10")
  )

  prices_1d <- structure(
    list(
      prices = prices
    ),
    ticker = "AAVL",
    period = "1d",
    class = "ticker_prices"
  )
  expected <- '{"prices":{"ticker":["AAVL","AAVL"],"time":["2018-11-14 11:03:42","2018-11-27 07:42:13"],"curr":[22,33]},"ticker":"AAVL","period":"1d"}'
  expect_equal(as.character(as_json(prices_1d)), expected)

  prices_all <- structure(
    list(
      prices = prices,
      peaks = peaks
    ),
    ticker = "AAVL",
    period = "all",
    class = "ticker_prices"
  )
  expected <- '{"prices":{"ticker":["AAVL","AAVL"],"time":["2018-11-14 11:03:42","2018-11-27 07:42:13"],"curr":[22,33]},"peaks":{"ticker":["AAVL","AAVL"],"date":["2018-10-10","2018-11-10"]},"ticker":"AAVL","period":"all"}'
  expect_equal(as.character(as_json(prices_all)), expected)
})

test_that("last_n_days", {
  data <- data.table(
    time = as_datetime(c(
      "2018-03-04",
      "2018-03-06 8:24:58",
      "2018-03-07",
      "2018-03-07 8:24:59"
    ))
  )

  expect_equal(last_n_days(data, 0), data.table(
    time = as_datetime("2018-03-07 08:24:59")
  ))

  expect_equal(last_n_days(data, 1), data.table(
    time = as_datetime(c(
      "2018-03-07",
      "2018-03-07 08:24:59"
    ))
  ))

  expect_equal(last_n_days(data, 2), data.table(
    time = as_datetime(c(
      "2018-03-06 8:24:58",
      "2018-03-07",
      "2018-03-07 08:24:59"
    ))
  ))

  expect_equal(last_n_days(data, 3, TRUE), data.table(
    time = as_datetime(c(
      "2018-03-04",
      "2018-03-06 8:24:58",
      "2018-03-07",
      "2018-03-07 08:24:59"
    ))
  ))
})

test_that("get_update_time", {
  data <- data.table(
    time = as_datetime(c("2018-03-04", "2018-03-07 08:24:59", "2018-03-04 22:22:55"))
  )
  expect_equal(get_update_time(data), as_datetime("2018-03-07 08:24:59"))
})

test_that("as_time_period", {
  tests <- list(
    c("1d", "1d"),
    c("1D", "1d"),
    c("5d", "5d"),
    c("5D", "5d"),
    c("1m", "1m"),
    c("1M", "1m"),
    c("all", "all"),
    c("ALL", "all"),
    c("", "1d"),
    c("nomatch", "1d"),
    c(123141, "1d")
  )
  for (test in tests) {
    x <- test[1]
    expected <- test[2]
    expect_equal(as_time_period(x), expected)
  }
})
