#' Create a new app
#'
#' Uses the following environment variables:
#'  * NEOSTOCKS_DATA_FILE   path to the stock data file or directory (defaults to example data)
#'  * NEOSTOCKS_UI_DIR      path to the UI directory (defaults to `dist`)
#'  * NEOSTOCKS_CACHE_DIR   path to the cache directory (optional)
#'  * NEOSTOCKS_ENABLE_API  if `true` (default), enable the internal API
#'
#' @export
new_app <- function() {
  stock_data_file <- Sys.getenv("NEOSTOCKS_DATA_FILE", stock_data_example())

  stock_data <- reactiveVal()

  summarize_data <- function() {
    data <- load_stock_data(stock_data_file)
    list(
      market_summary = summarize_market(data),
      price_data = get_price_data(data),
      update_time = get_update_time(data)
    )
  }

  update_stock_data <- function() {
    log_info("updating stock data")
    start_time <- Sys.time()

    future::future({
      summarize_data()
    }, seed = TRUE) %>% then(function(result) {
      stock_data(result)
      end_time <- Sys.time()
      log_info("updated in ", format(end_time - start_time))
      if (nzchar(cache_dir)) {
        dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
        saveRDS(result, file.path(cache_dir, "data.rds"))
      }
    })
  }

  last_update_time <- NULL

  # Load cached data
  cache_dir <- Sys.getenv("NEOSTOCKS_CACHE_DIR")
  if (nzchar(cache_dir)) {
    cache_file <- file.path(cache_dir, "data.rds")
    if (file.exists(cache_file)) {
      log_info("loading stock data from cache")
      cache_data <- readRDS(cache_file)
      stock_data(cache_data)
      last_update_time <- cache_data$update_time
    }
  }

  # Load initial data
  data <- load_stock_data(stock_data_file)
  if (!identical(last_update_time, get_update_time(data))) {
    update_stock_data()
  }

  ui_dir <- Sys.getenv("NEOSTOCKS_UI_DIR", "dist")
  ui_template_file <- file.path(ui_dir, "index.html")
  ui_handler <- new_ui(ui_template_file, stock_data)
  addResourcePath("static", file.path(ui_dir, "static"))

  if (Sys.getenv("NEOSTOCKS_ENABLE_API", "true") == "true") {
    api_handler <- new_api(stock_data)
    ui <- function(req) {
      res <- api_handler(req)
      if (is.null(res)) {
        res <- ui_handler(req)
      }
      res
    }
  } else {
    ui <- ui_handler
  }

  server <- new_server(stock_data)

  on_start <- function() {
    # Poll for updates in the background
    watcher <- FileWatcher$new(stock_data_file, update_stock_data, 5)
    watcher$start()
    onStop(watcher$stop)
  }

  shinyApp(ui, server, onStart = on_start, uiPattern = ".*")
}
