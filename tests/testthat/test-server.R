test_that("server", {
  stock_data <- reactive(list(
    price_data = "price_data",
    market_summary = "market_summary",
    update_time = as_datetime("2018-04-05")
  ))

  server <- new_server(stock_data)

  mock_session <- function() {
    e <- new.env()
    e$allowReconnect = function(value) {
      e$reconnect <- value
    }
    e$msgs <- list()
    e$sendCustomMessage = function(type, message) {
      msg <- list(type = type, message = message)
      e$msgs[[length(e$msgs) + 1]] <- msg
      e$last_msg <- msg
    }
    e
  }

  input <- reactiveValues(update_time = as_datetime("2018-04-05"))
  output <- list()
  session <- mock_session()

  get_ticker_prices <- function(data, ticker, period) {
    list(data = data, ticker = ticker, period = period)
  }

  flush <- function() {
    with_mock(
      "neostocks:::get_ticker_prices" = get_ticker_prices,
      shiny:::flushReact()
    )
  }

  # Session initialization
  server(input, output, session)
  flush()
  expect_true(session$reconnect)
  expect_true(length(session$msgs) == 0)

  # Get ticker
  input$ticker <- list(ticker = "AAVL", period = "5d")
  flush()
  expect_true(length(session$msgs) == 1)
  expected_msg <- as_json(list(data = "price_data", ticker = "AAVL", period = "5d"))
  expect_equal(session$last_msg, list(type = "ticker_prices", message = expected_msg))

  # Get market summary
  input$last_update <- list(time = as_datetime("2018-04-01"))
  flush()
  expect_true(length(session$msgs) == 2)
  expect_equal(
    session$last_msg,
    list(type = "market_summary", message = as_json("market_summary"))
  )
})
