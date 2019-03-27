app_with_api <- function(app, api_handler) {
  ui_handler <- app$httpHandler
  app$httpHandler <- function(req) {
    res <- api_handler(req)
    if (is.null(res)) {
      res <- ui_handler(req)
    }
    res
  }
  app
}

new_api <- function(stock_data) {
  summary_data <- function() {
    isolate(stock_data()$market_summary$summary_data)
  }

  r <- router(
    list(
      route("/api/tickers", tickers_handler(summary_data), query = "period"),
      route("/api/tickers/:ticker", ticker_handler(summary_data), query = "period")
    )
  )

  function(req) {
    tryCatch({
      r$handle(req)
    },
    error = function(e) {
      log_info(sprintf("API error: %s", e))
      internal_server_error_response()
    })
  }
}

# Get all tickers
tickers_handler <- function(summary_data) {
  function(period = "1d") {
    if (is.null(period)) {
      summary <- summary_data()
      summary <- lapply(summary, function(data) merge(companies, data, by = "ticker"))
    } else {
      period <- as_time_period(period)
      summary <- summary_data()[[period]]
      summary <- merge(companies, summary, by = "ticker")
    }
    content <- as_json(summary)
    json_response(content)
  }
}

# Get a ticker
ticker_handler <- function(summary_data) {
  function(ticker, period = "1d") {
    stock_ticker <- toupper(ticker)
    if (!stock_ticker %in% companies$ticker) {
      return(not_found_response())
    }
    if (is.null(period)) {
      summary <- lapply(summary_data(), function(data) data[ticker == stock_ticker])
      summary <- lapply(summary, function(data) {
        as.list(merge(companies, data, by = "ticker"))
      })
    } else {
      period <- as_time_period(period)
      summary <- summary_data()[[period]][ticker == stock_ticker]
      summary <- as.list(merge(companies, summary, by = "ticker"))
    }
    content <- as_json(summary)
    json_response(content)
  }
}

json_response <- function(content, content_type = "application/json") {
  shiny:::httpResponse(
    status = 200,
    content_type = content_type,
    content = content
  )
}

not_found_response <- function() {
  shiny:::httpResponse(status = 404)
}

internal_server_error_response <- function() {
  shiny:::httpResponse(status = 500)
}
