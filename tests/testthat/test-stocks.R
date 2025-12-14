test_that("load_stock_data", {
  get_archived_prices <- function() {
    data.table(
      ticker = "VPTS",
      time = as_datetime("2007-10-10"),
      volume = 100,
      open = 20,
      curr = 22
    )
  }

  data <- with_mocked_bindings(
    get_archived_prices = get_archived_prices,
    load_stock_data("data/stocks.csv")
  )

  expected <- data.table(
    ticker = c("VPTS", "AAVL", "ACFI", "BB", "NEODAQ", "NEODAQ"),
    time = as_datetime(c("2007-10-10", "2018-07-01 10:30:00", "2018-07-01 10:30:00",
                         "2018-07-01 10:30:00", "2007-10-10", "2018-07-01 10:30:00")),
    volume = c(100, 0, 549255, 0, 100, 549255),
    open = c(20, 8, 15, 6, 20, 29),
    curr = c(22, 9, 15, 6, 22, 30)
  )

  expect_equal(data, expected)
})

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


test_that("summarize_market", {
  time_day <- 3600 * 24
  data <- data.table(
    time = rep(as_datetime("2018-03-03"), 5) - c(0, 1, 5, 30, 365) * time_day,
    ticker = rep("AAVL", 5),
    open = c(1, 30, 2, 4, 5),
    curr = c(1, 40, 3, 4, 5),
    volume = c(1, 2, 3, 4, 5)
  )

  summarize_volume_price <- function(data) {
    data.table(
      curr = c(9, 10, 15, 20, 21),
      pct = c(0.1, 0.1, 0.1, 0.1, 0.1)
    )
  }
  summarize_volume_day <- function(data) {
    data
  }
  predict_prices <- function(data) {
    data.table(
      curr = c(30, 40, 50, 60, 70, 80, 90, 100),
      p = c(0.123, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1),
      days_from_15 = c(3, 4, 5, 6, 7, 8, 9, 10)
    )
  }

  summ <- with_mocked_bindings(
    predict_prices = predict_prices,
    summarize_volume_price = summarize_volume_price,
    summarize_volume_day = summarize_volume_day,
    summarize_market(data)
  )

  expected <- list(
    summary_data = list(
      "1d" = data.table(ticker = "AAVL", volume = 2, open = 30, curr = 40,
                        high = 40, time_high = as_datetime("2018-03-02"),
                        low = 1, avg = 20.5, median = 20.5, sd = 27.6,
                        change = 10, range = 39, period = "1d",
                        update_time = as_datetime("2018-03-03"),
                        update_time_nst = "2018-03-03",
                        time_high_nst = "2018-03-02"),
      "5d" = data.table(ticker = "AAVL", volume = 3, open = 1, curr = 3,
                        high = 40, time_high = as_datetime("2018-03-02"),
                        low = 1, avg = 14.7, median = 3, sd = 22,
                        change = 2, range = 39, period = "5d",
                        update_time = as_datetime("2018-03-03"),
                        update_time_nst = "2018-03-03",
                        time_high_nst = "2018-03-02"),
      "1m" = data.table(ticker = "AAVL", volume = 4, open = 1, curr = 4,
                        high = 40, time_high = as_datetime("2018-03-02"),
                        low = 1, avg = 12, median = 3.5, sd = 18.7,
                        change = 3, range = 39, period = "1m",
                        update_time = as_datetime("2018-03-03"),
                        update_time_nst = "2018-03-03",
                        time_high_nst = "2018-03-02"),
      "all" = data.table(ticker = "AAVL", curr = 5,
                        high = 40, time_high = as_datetime("2018-03-02"),
                        low = 1, avg = 10.6, median = 4, sd = 16.5,
                        pct_95 = -Inf, num_peaks = 1, avg_peak = 40,
                        avg_days_peak = 5, last_peak = as_datetime("2018-03-02"),
                        med_peak = 40, period = "all",
                        update_time = as_datetime("2018-03-03"),
                        update_time_nst = "2018-03-03",
                        time_high_nst = "2018-03-02",
                        last_peak_nst = "2018-03-02",
                        key = "ticker")
    ),
    hot_stocks = list(
      list(ticker = "AAVL", new = TRUE)
    ),
    volume_by_price = data.table(
      curr = c(10, 15, 20),
      pct = c(0.1, 0.1, 0.1)
    ),
    volume_by_day = data.table(
      time = as_datetime(c("2018-03-03", "2018-03-02", "2018-02-26", "2018-02-01")),
      ticker = c("AAVL", "AAVL", "AAVL", "AAVL"),
      open = c(1, 30, 2, 4),
      curr = c(1, 40, 3, 4),
      volume = c(1, 2, 3, 4)
    ),
    price_dist = data.table(
      curr = c(30, 40, 50, 60, 70),
      p = c(0.12, 0.1, 0.1, 0.1, 0.1)
    ),
    days_from_15 = data.table(
      curr = c(30, 40, 50, 60, 70, 80, 90),
      days_from_15 = c(3, 4, 5, 6, 7, 8, 9)
    ),
    update_time = as_datetime("2018-03-03")
  )

  expect_equal(summ, expected)
})

test_that("find_hot_stocks", {
  summary_data <- list(
    "1d" = data.table(
      ticker = c("AAVL", "BUZZ"),
      change = c(0, 0),
      curr = c(30, 29),
      update_time = as_date(c("2018-03-03", "2018-03-03"))
    ),
    "5d" = data.table(
      ticker = c("AAVL", "BUZZ"),
      change = c(0, 0)
    ),
    "1m" = data.table(
      ticker = c("AAVL", "BUZZ"),
      change = c(0, 0)
    ),
    "all" = data.table(
      ticker = c("AAVL", "BUZZ"),
      last_peak = c(as_date("2018-03-03") - 3, as_date("2018-03-03") - 4)
    )
  )

  expect_length(find_hot_stocks(summary_data), 0)

  # 1d
  data <- copy(summary_data)
  data[["1d"]][ticker == "AAVL", change := 5]
  expect_equal(find_hot_stocks(data), list(list(ticker = "AAVL", new = TRUE)))

  # 5d
  data <- copy(summary_data)
  data[["5d"]][ticker == "AAVL", change := 5]
  expect_equal(find_hot_stocks(data), list(list(ticker = "AAVL", new = TRUE)))

  # 1m
  data <- copy(summary_data)
  data[["1m"]][ticker == "AAVL", change := 15]
  expect_equal(find_hot_stocks(data), list(list(ticker = "AAVL", new = TRUE)))

  # all
  data <- copy(summary_data)
  data[["all"]][ticker == "AAVL", last_peak := data[["1d"]]$update_time[1] - 2]
  expect_equal(find_hot_stocks(data), list(list(ticker = "AAVL", new = TRUE)))

  # Min price
  data <- copy(summary_data)
  data[["1d"]][ticker == "BUZZ", change := 5]
  expect_length(find_hot_stocks(data), 0)

  # Not new
  data <- copy(summary_data)
  data[["1d"]][ticker == "BUZZ", c("change", "curr") := list(5, 30)]
  expect_equal(find_hot_stocks(data), list(list(ticker = "BUZZ", new = FALSE)))
})

test_that("get_price_data", {
  time_day <- 3600 * 24
  data <- data.table(
    time = rep(as_datetime("2018-03-03"), 5) - c(0, 1, 5, 30, 365) * time_day,
    ticker = rep("AAVL", 5),
    curr = c(1, 40, 3, 4, 5)
  )

  prices <- get_price_data(data)
  expect_equal(prices[["1d"]], data[1:2, ])
  expect_equal(prices[["5d"]], data[1:3, ])
  expect_equal(prices[["1m"]], data[1:4, ])
  expect_equal(prices[["all"]], data[, list(time = date(time), ticker, curr)])
  expect_equal(prices$peaks, peaks_by_day(data))
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

  expect_equal(last_n_days(data, 3), data.table(
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
