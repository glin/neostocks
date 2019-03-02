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

get_archived_prices <- function() {
  file <- system.file("extdata", "archived_prices.csv", package = "neostocks")
  read_stock_data(file)
}

read_stock_data <- function(file) {
  data <- data.table::fread(file)
  data[, time := as_datetime(time)]
  data
}
