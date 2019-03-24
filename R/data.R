get_companies <- function() {
  file <- system.file("extdata", "companies.json", package = "neostocks")
  companies <- jsonlite::read_json(file)
  tickers <- names(companies)
  companies <- data.table::rbindlist(companies)
  companies <- cbind(ticker = tickers, companies)
  companies <- rbind(
    companies,
    list(ticker = "NEODAQ", company = "Neopian Stock Market"),
    fill = TRUE
  )
  companies
}

companies <- get_companies()

company_name <- function(stock_ticker) {
  companies[ticker == stock_ticker, company]
}

get_archived_prices <- function() {
  file <- system.file("extdata", "archived_prices.csv", package = "neostocks")
  read_stock_data(file)
}

read_stock_data <- function(file) {
  data <- data.table::fread(file)
  data[, time := as_datetime(time)]
  data
}

stock_data_example <- function() {
  system.file("extdata", "neostocks.csv", package = "neostocks")
}
