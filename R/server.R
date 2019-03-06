new_server <- function(stock_data) {
  function(input, output, session) {
    session$allowReconnect(TRUE)

    update_time <- reactive(stock_data()$update_time)
    price_data <- reactive(stock_data()$price_data)
    market_summary <- reactive(stock_data()$market_summary)

    ticker_prices <- reactive({
      req(input$ticker)
      ticker <- input$ticker$ticker
      period <- input$ticker$period
      get_ticker_prices(price_data(), ticker, period)
    })

    observe({
      prices <- ticker_prices()
      session$sendCustomMessage("ticker_prices", as_json(prices))
    })

    observe({
      req(input$last_update)
      prev_time <- input$last_update$time
      current_time <- update_time()
      if (as_datetime(prev_time) != current_time) {
        summary <- market_summary()
        session$sendCustomMessage("market_summary", as_json(summary))
      }
    })
  }
}
