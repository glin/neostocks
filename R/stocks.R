load_stock_data <- function(file) {
  data <- read_stock_data(file)

  # Add archived prices
  archived_prices <- get_archived_prices()
  data <- rbind(archived_prices, data, fill = TRUE)

  # Add Neodaq composite index
  index <- calc_market_index(data)
  data <- rbind(data, index)
  data
}

# Calculate Neodaq composite index
calc_market_index <- function(data) {
  # Don't remove NAs to omit days with missing data
  data[, list(
    ticker = "NEODAQ",
    volume = sum(volume),
    open = sum(open),
    curr = sum(curr)
  ), by = time]
}

summarize_market <- function(data) {
  update_time <- get_update_time(data)

  data_1d <- last_n_days(data, 1)
  data_5d <- last_n_days(data, 5)
  data_1m <- last_n_days(data, 30)

  summary_data <- list(
    "1d" = summarize_day(data_1d),
    "5d" = summarize_period(data_5d),
    "1m" = summarize_period(data_1m),
    all = summarize_all(data)
  )

  # Add period and update time
  for (period in names(summary_data)) {
    summ <- summary_data[[period]]
    summ[, period := period]
    summ[, update_time := update_time]
    summ[, update_time_nst := as.character(update_time)]
    summ[, time_high_nst := as.character(time_high)]
    if ("last_peak" %in% names(summ)) {
      summ[, last_peak_nst := as.character(last_peak)]
    }
  }

  # Hot stocks
  hot_stocks <- find_hot_stocks(summary_data)

  # Volume by price (10-20 NP, where most stocks are bought)
  volume_data <- data[!is.na(volume) & ticker != "NEODAQ"]
  volume_by_price <- summarize_volume_price(volume_data)
  volume_by_price <- volume_by_price[curr >= 10 & curr <= 20, list(curr, pct)]

  # Volume by day (last 4 months)
  data_4m <- last_n_days(volume_data, 120, full_days = TRUE)
  volume_by_day <- summarize_volume_day(data_4m)

  # Stock price prediction
  predicted <- predict_prices(data[ticker != "NEODAQ"])
  price_dist <- predicted[curr <= 70, list(curr, p = round(p, 2))]
  days_from_15 <- predicted[curr %in% seq(30, 90, 10), list(curr, days_from_15)]

  list(
    summary_data = summary_data,
    hot_stocks = hot_stocks,
    volume_by_price = volume_by_price,
    volume_by_day = volume_by_day,
    price_dist = price_dist,
    days_from_15 = days_from_15,
    update_time = update_time
  )
}

# Find hot stocks with large increases or recent peaks
find_hot_stocks <- function(summary_data) {
  update_time <- summary_data[["1d"]]$update_time[1]
  hot_stocks <- unique(c(
    summary_data[["1d"]][change >= 5, ticker],
    summary_data[["5d"]][change >= 5, ticker],
    summary_data[["1m"]][change >= 15, ticker],
    summary_data[["all"]][difftime(update_time, last_peak, units = "days") <= 2, ticker]
  ))

  # Generally, we only care about stocks at 30 NP or above
  min_price_stocks <- summary_data[["1d"]][curr >= 30, ticker]
  hot_stocks <- hot_stocks[hot_stocks %in% min_price_stocks]
  hot_stocks <- hot_stocks[hot_stocks != "NEODAQ"]

  recent_peak_stocks <- summary_data[["all"]][difftime(update_time, last_peak, units = "days") <= 3, ticker]
  hot_stocks <- lapply(hot_stocks, function(ticker) {
    list(ticker = ticker, new = ticker %in% recent_peak_stocks)
  })

  hot_stocks
}

# Get price data for each time period
get_price_data <- function(data) {
  prices_1d <- last_n_days(data, 1)[, list(time, ticker, curr)]
  prices_5d <- last_n_days(data, 5)[, list(time, ticker, curr)]
  prices_1m <- last_n_days(data, 30)[, list(time, ticker, curr)]
  # Aggregate by day
  prices_all <- data[, list(curr = max(curr)), by = list(time = date(time), ticker)]

  peaks <- peaks_by_day(data)

  list(
    "1d" = prices_1d,
    "5d" = prices_5d,
    "1m" = prices_1m,
    all = prices_all,
    peaks = peaks
  )
}

# Get price data for a specific ticker and time period
get_ticker_prices <- function(price_data, ticker, period) {
  period <- as_time_period(period)
  prices <- price_data[[period]]
  if (is.null(prices)) {
    return(NULL)
  }

  stock_ticker <- toupper(ticker)
  prices <- prices[ticker == stock_ticker, list(time, curr)]
  if (nrow(prices) == 0) {
    return(NULL)
  }

  if (period == "all") {
    peaks <- price_data$peaks[ticker == stock_ticker, date]
    data <- list(prices = prices, peaks = peaks)
  } else {
    data <- list(prices = prices)
  }

  structure(
    data,
    ticker = stock_ticker,
    period = period,
    class = "ticker_prices"
  )
}

#' @export
as_json.ticker_prices <- function(x, ...) {
  data <- unclass(x)
  data$ticker <- attr(x, "ticker")
  data$period <- attr(x, "period")
  as_json(data, dataframe = "columns", POSIXt = "string", UTC = FALSE, ...)
}

get_update_time <- function(data) {
  max(data$time)
}

# Get last N days of data, optionally rounding the first day to a full day
last_n_days <- function(data, n, full_days = FALSE) {
  time_day <- 3600*24
  start_time <- max(data$time) - n * time_day
  if (full_days) {
    start_time <- floor_date(start_time)
  }
  data[time >= start_time]
}

as_time_period <- function(period = "1d") {
  period <- tolower(period)
  if (length(period) == 0 || !period %in% c("1d", "5d", "1m", "all")) {
    period <- "1d"
  }
  period
}
