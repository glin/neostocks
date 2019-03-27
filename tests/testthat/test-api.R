context("api")

test_that("new_api", {
  stock_data <- reactiveVal(list(
    market_summary = list(summary_data = list(
      "1d" = data.table(ticker = "YIPP", curr = 11),
      "5d" = data.table(ticker = "YIPP", curr = 22)
    ))
  ))

  api_handler <- new_api(stock_data)

  request <- function(path, query = NULL) {
    api_handler(list(PATH_INFO = path, QUERY_STRING = query))
  }

  # Fall-through
  expect_equal(request("/"), NULL)
  expect_equal(request("/bad"), NULL)

  # Tickers
  res_tickers <- request("/api/tickers")
  expect_equal(res_tickers$status, 200)
  expect_equal(
    as.character(res_tickers$content),
    '{"1d":[{"ticker":"YIPP","company":"Yippee!","id":"23","logo_id":"2","curr":11}],"5d":[{"ticker":"YIPP","company":"Yippee!","id":"23","logo_id":"2","curr":22}]}'
  )

  # Ticker
  res_tickers <- request("/api/tickers/yipp")
  expect_equal(res_tickers$status, 200)
  expect_equal(
    as.character(res_tickers$content),
    '{"1d":{"ticker":"YIPP","company":"Yippee!","id":"23","logo_id":"2","curr":11},"5d":{"ticker":"YIPP","company":"Yippee!","id":"23","logo_id":"2","curr":22}}'
  )

  res_tickers <- request("/api/tickers/yipp", query = "period=5d")
  expect_equal(res_tickers$status, 200)
  expect_equal(
    as.character(res_tickers$content),
    '{"ticker":"YIPP","company":"Yippee!","id":"23","logo_id":"2","curr":22}'
  )

  res_not_found <- request("/api/tickers/boom")
  expect_equal(res_not_found$status, 404)

  # Server error
  stock_data <- reactiveVal(list(
    market_summary = list(summary_data = list(
      "all" = data.table(error = "bad")
    ))
  ))
  api_handler <- new_api(stock_data)
  res_error <- request("/api/tickers/yipp", query = "period=all")
  expect_equal(res_error$status, 500)
})

test_that("tickers_handler", {
  summary_data <- function() {
    list(
      "1d" = data.table(ticker = "YIPP", curr = 11),
      "5d" = data.table(ticker = "YIPP", curr = 22)
    )
  }
  handler <- tickers_handler(summary_data)

  res_1d <- handler("1d")
  expect_equal(res_1d$status, 200)
  expect_equal(res_1d$content_type, "application/json")
  expect_equal(
    as.character(res_1d$content),
    '[{"ticker":"YIPP","company":"Yippee!","id":"23","logo_id":"2","curr":11}]'
  )

  res_5d <- handler("5d")
  expect_equal(res_5d$status, 200)
  expect_equal(res_5d$content_type, "application/json")
  expect_equal(
    as.character(res_5d$content),
    '[{"ticker":"YIPP","company":"Yippee!","id":"23","logo_id":"2","curr":22}]'
  )

  # Case insensitivity
  expect_equal(handler("5d"), handler("5D"))
})

test_that("ticker_handler", {
  summary_data <- function() {
    list(
      "1d" = data.table(ticker = "YIPP", curr = 11),
      "5d" = data.table(ticker = "YIPP", curr = 22)
    )
  }
  handler <- ticker_handler(summary_data)

  # OK response
  res_ok <- handler("YIPP", "5d")
  expect_equal(res_ok$status, 200)
  expect_equal(res_ok$content_type, "application/json")
  expect_equal(
    as.character(res_ok$content),
    '{"ticker":"YIPP","company":"Yippee!","id":"23","logo_id":"2","curr":22}'
  )

  # Case insensitivity
  expect_equal(handler("YIPP"), handler("yipp"))
  expect_equal(handler("YIPP", "5d"), handler("yipp", "5D"))

  # Default time period = 1d
  expect_equal(handler("YIPP"), handler("YIPP", "1d"))
  expect_equal(handler("YIPP"), handler("YIPP", "badday"))

  # Not found response
  res_not_found <- handler("BOOM")
  expect_equal(res_not_found$status, 404)
})

test_that("app_with_api", {
  app <- shinyApp(ui = function(req) "ui", server = function() {})
  api_handler <- function(req) {
    if (req$PATH_INFO == "/api") {
      return("api")
    }
  }
  app <- app_with_api(app, api_handler)
  expect_equal(app$httpHandler(list(PATH_INFO = "/api")), "api")
})
