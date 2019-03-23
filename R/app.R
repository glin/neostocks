#' Create a new app
#'
#' Uses the following environment variables:
#'  * NEOSTOCKS_DATA_FILE   path to the stock data file
#'  * NEOSTOCKS_UI_DIR      path to the UI directory
#'  * NEOSTOCKS_ENABLE_API  if `true`, enable the internal API
#'
#' @export
new_app <- function() {
  stock_data_file <- Sys.getenv("NEOSTOCKS_DATA_FILE", stock_data_example())

  summarize_data <- function() {
    data <- load_stock_data(stock_data_file)
    list(
      market_summary = summarize_market(data),
      price_data = get_price_data(data),
      update_time = get_update_time(data)
    )
  }

  stock_data <- reactiveVal()

  ui_dir <- Sys.getenv("NEOSTOCKS_UI_DIR", "dist")
  ui_template_file <- file.path(ui_dir, "index.html")
  ui <- new_ui(ui_template_file, stock_data)

  server <- new_server(stock_data)

  update_stock_data <- function() {
    log_info("updating stock data")
    start_time <- Sys.time()

    future::future({
      summarize_data()
    }) %>% then(function(result) {
      stock_data(result)
      end_time <- Sys.time()
      log_info("updated in ", format(end_time - start_time))
    })
  }

  on_start <- function() {
    addResourcePath("static", file.path(ui_dir, "static"))

    # Load initial data
    initial_data <- summarize_data()
    stock_data(initial_data)

    # Poll for updates in the background
    watcher <- FileWatcher$new(stock_data_file, update_stock_data, 5)
    watcher$start()
    onStop(watcher$stop)
  }

  app <- shinyApp(ui, server, onStart = on_start, uiPattern = "^.*$")

  if (Sys.getenv("NEOSTOCKS_ENABLE_API") == "true") {
    api <- new_api(stock_data)
    app <- app_with_api(app, api)
  }

  app
}
