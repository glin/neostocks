context("data")

test_that("get_companies", {
  companies <- get_companies()
  expect_identical(names(companies), c("ticker", "company", "id", "logo_id"))
  expect_true(nrow(companies) == 44)
})

test_that("archived_prices", {
  prices <- get_archived_prices()
  expect_identical(names(prices), c("time", "ticker", "curr"))
})

test_that("read_stock_data", {
  data <- read_stock_data("data/stocks.csv")
  expected <- data.table::data.table(
    time = as_datetime(c("2018-07-01T17:30:00Z", "2018-07-01T17:30:00Z", "2018-07-01T17:30:00Z")),
    ticker = c("AAVL", "ACFI", "BB"),
    volume = c(0, 549255, 0),
    open = c(8, 15, 6),
    curr = c(9, 15, 6)
  )
  expect_equal(data, expected)
})
