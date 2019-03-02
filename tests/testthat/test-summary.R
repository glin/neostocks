context("summary")

test_that("summarize_day", {
  data <- read_stock_data(stock_data_example())
  summ <- summarize_day(data[ticker %in% c("AAVL", "BUZZ")])
  expected <- data.table(
    ticker = c("AAVL", "BUZZ"),
    volume = c(8240, 123184),
    open = c(20, 17),
    curr = c(20, 16),
    high = c(25, 88),
    time_high = as_datetime(c("2018-07-29 12:00:00", "2018-07-08 18:30:00")),
    low = c(6, 16),
    avg = c(12.1, 55.4),
    median = c(11, 60),
    sd = c(4.6, 17.9),
    change = c(0, -1),
    range = c(19, 72)
  )
  expect_equal(summ, expected)
})

test_that("summarize_period", {
  data <- read_stock_data(stock_data_example())
  summ <- summarize_period(data[ticker %in% c("AAVL", "BUZZ")])
  expected <- data.table(
    ticker = c("AAVL", "BUZZ"),
    volume = c(4281450, 416104),
    open = c(8, 53),
    curr = c(20, 16),
    high = c(25, 88),
    time_high = as_datetime(c("2018-07-29 12:00:00", "2018-07-08 18:30:00")),
    low = c(6, 16),
    avg = c(12.1, 55.4),
    median = c(11, 60),
    sd = c(4.6, 17.9),
    change = c(12, -37),
    range = c(19, 72)
  )
  expect_equal(summ, expected)
})

test_that("summarize_all", {
  data <- read_stock_data(stock_data_example())
  summ <- summarize_all(data[ticker %in% c("AAVL", "BUZZ")])
  setkey(summ, NULL)
  expected <- data.table(
    ticker = c("AAVL", "BUZZ"),
    curr = c(20, 16),
    high = c(25, 88),
    time_high = as_datetime(c("2018-07-29 12:00:00", "2018-07-08 18:30:00")),
    low = c(6, 16),
    avg = c(12.1, 55.4),
    median = c(11, 60),
    sd = c(4.6, 17.9),
    pct_95 = c(21, 82),
    num_peaks = c(NA, 1),
    avg_peak = c(NA, 88),
    avg_days_peak = c(NA, 31),
    last_peak = as_datetime(c(NA, "2018-07-08 18:30:00")),
    med_peak = c(NA, 88)
  )
  expect_equal(summ, expected)
})

test_that("peaks_by_day", {
  data <- read_stock_data(stock_data_example())
  summ <- peaks_by_day(data[ticker %in% c("AAVL", "BUZZ", "VPTS")])
  expected <- data.table(
    ticker = c("BUZZ", "VPTS"),
    time = as_datetime(c("2018-07-08 18:30:00", "2018-07-22 07:30:00")),
    volume = c(6485, 536),
    open = c(78, 1564),
    curr = c(88, 1583),
    date = as_date(c("2018-07-08", "2018-07-22"))
  )
  expect_equal(summ, expected)
})

test_that("get_peaks", {
  prices <- c(6, 6, 7, 36, 15, 22, 31, 9, 15, 6, 7, 8, 9, 10, 35)

  # Whole period peaks: 36, 35
  peak_inds <- get_peaks(prices, days = 15, min_val = 0, threshold = 0)
  expect_equal(peak_inds, c(4, 15))

  # 3 day peaks: 36, 31, 35
  peak_inds <- get_peaks(prices, days = 3, min_val = 0, threshold = 0)
  expect_equal(peak_inds, c(4, 7, 15))

  # Peaks at 36 or above
  peak_inds <- get_peaks(prices, days = 3, min_val = 36, threshold = 0)
  expect_equal(peak_inds, 4)

  # Peaks with range 27 or above
  peak_inds <- get_peaks(prices, days = 3, min_val = 0, threshold = 27)
  expect_equal(peak_inds, 4)
})

test_that("summarize_volume_price", {
  data <- data.table(
    ticker = c("AAVL", "AAVL", "AAVL", "BUZZ", "BUZZ", "BUZZ"),
    curr = c(9, 10, 10, 13, 50, 50),
    volume = c(100, 50, 100, 25, 50, 75)
  )
  summ <- summarize_volume_price(data)
  expected <- data.table(
    curr = c(9, 10, 13, 50),
    volume = c(0, 50, 25, 25),
    pct = c(0, 50, 25, 25)
  )
  expect_equal(summ, expected)
})

test_that("summarize_volume_day", {
  data <- data.table(
    time = as_datetime(c(rep("2018-01-05", 4), rep("2018-01-07", 2))),
    ticker = c("AAVL", "AAVL", "AAVL", "BUZZ", "BUZZ", "BUZZ"),
    curr = c(9, 10, 10, 13, 50, 50),
    volume = c(100, 50, 100, 25, 50, 75)
  )
  summ <- summarize_volume_day(data)
  expected <- data.table(
    date = as_date(c("2018-01-05", "2018-01-07")),
    volume = c(225, 75)
  )
  expect_equal(summ, expected)
})

test_that("volume_change", {
  # No change
  volume <- c(10)
  chg <- volume_change(volume)
  expect_equal(chg, 0)

  # No resets
  volume <- c(10, 20, 30)
  chg <- volume_change(volume)
  expect_equal(chg, c(10, 10, 0))

  # With resets: 10 to 30, reset, 10 to 50, reset, 40 to 60
  volume <- c(10, 20, 30, 0, 10, 50, 40, 50, 60)
  chg <- volume_change(volume)
  expected <- c(10, 10, 0, 10, 40, 40, 10, 10, 0)
  expect_equal(chg, expected)
})

test_that("total_volume", {
  # No change
  volume <- c(10)
  total <- total_volume(volume)
  expect_equal(total, 10)

  # No resets
  volume <- c(10, 20, 30)
  total <- total_volume(volume)
  expect_equal(total, 30)

  # With resets
  volume <- c(10, 20, 30, 0, 10, 50, 40, 50, 60)
  total <- total_volume(volume)
  expect_equal(total, 140)
})
