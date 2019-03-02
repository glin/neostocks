context("predict")

test_that("predict_prices", {
  data <- read_stock_data(stock_data_example())
  predicted <- predict_prices(data[time <= as_date("2018-07-15")])

  p <- predicted[curr %in% c(6, 10, 15, 30, 60, 90), p]
  expected_p <- c(8.03, 7.18, 4.46, 0.348, 0.176, 0.052)
  expect_equal(p, expected_p, tolerance = 0.001)

  expect_true(predicted[curr <= 15, all(is.na(days_from_15))])
  days <- predicted[curr %in% c(20, 30, 45, 60, 90, 120), days_from_15]
  expected_days <- c(50, 196, 410, 559, 952, 3855)
  expect_equal(days, expected_days)
})
