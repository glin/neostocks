new_ui <- function(template_file, stock_data) {
  r <- router(
    list(
      route("/", home_page),
      route("/bargain", bargain_page),
      route("/hot", hot_page),
      route("/tickers/:ticker", ticker_page, query = "period"),
      route("/index", index_page, query = "period"),
      route("/trends", trends_page),
      route("/settings", settings_page),
      route("/about", about_page),
      route("/privacy", privacy_page),
      route("/bargain", bargain_page),
      route(".*", not_found_page)
    )
  )

  function(req) {
    page <- r$handle(req)
    ui_template(
      template_file,
      isolate(stock_data()),
      title = page$title,
      description = page$description,
      ticker = page$ticker,
      period = page$period
    )
  }
}

home_page <- list(
  description = "Real-time stock tracker for the Neopets Stock Market. Explore stock history, get price alerts, and find the best stocks to buy and sell."
)

bargain_page <- list(title = "Bargain")

ticker_page <- function(ticker, period) {
  if (!ticker %in% companies$ticker) {
    return(not_found_page)
  }
  list(
    title = ticker,
    ticker = ticker,
    period = period
  )
}

index_page <- function(period) {
  list(
    title = "Neodaq Index",
    ticker = "NEODAQ",
    period = period
  )
}

hot_page <- list(title = "Hot")

trends_page <- list(title = "Trends")

settings_page <- list(title = "Settings")

about_page <- list(title = "About")

privacy_page <- list(title = "Privacy Policy")

not_found_page <- list(title = "page not found")

ui_template <- function(file, stock_data, title = NULL, description = NULL,
                        ticker = NULL, period = NULL) {
  data_script <- tags$script(HTML(
    sprintf("window.__data__ = %s", as_json(stock_data$market_summary))
  ))

  if (!is.null(ticker)) {
    ticker_prices = get_ticker_prices(stock_data$price_data, ticker, period)
    data_script <- list(
      data_script,
      tags$script(HTML(
        sprintf("window.__ticker_data__ = %s", as_json(ticker_prices))
      ))
    )
  }

  title <- document_title(page_title = title)

  if (is.null(description)) {
    description <- home_page$description
  }

  htmlTemplate(
    file,
    data_script = data_script,
    head = list(
      tags$meta(property = "og:title", content = title),
      tags$meta(name = "description", content = description),
      tags$meta(property = "og:description", content = description),
      tags$title(title)
    )
  )
}

document_title <- function(page_title = NULL) {
  title <- "neostocks"
  if (!is.null(page_title)) {
    title <- paste(page_title, "-", title)
  }
  title
}
