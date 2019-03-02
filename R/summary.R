# Summarize stocks for the current day
summarize_day <- function(data) {
  summ <- data[, list(
    volume = volume[.N],
    open = open[.N],
    curr = curr[.N],
    high = max(curr, na.rm = TRUE),
    time_high = .SD[which.max(curr), time],
    low = min(curr, na.rm = TRUE),
    avg = round(mean(curr, na.rm = TRUE), 1),
    median = median(curr, na.rm = TRUE),
    sd = round(sd(curr, na.rm = TRUE), 1)
  ), by = ticker]

  summ[, change := curr - open]
  summ[, range := high - low]
  summ
}

# Summarize stocks over a period of time
summarize_period <- function(data) {
  summ <- data[, list(
    volume = total_volume(volume),
    open = open[which(!is.na(open))[1]],
    curr = curr[.N],
    high = max(curr, na.rm = TRUE),
    time_high = .SD[which.max(curr), time],
    low = min(curr, na.rm = TRUE),
    avg = round(mean(curr, na.rm = TRUE), 1),
    median = median(curr, na.rm = TRUE),
    sd = round(sd(curr, na.rm = TRUE), 1)
  ), by = ticker]

  if ("NEODAQ" %in% summ$ticker) {
    # Correct index volume since summed volumes aren't reliable
    index_volume <- summ[ticker != "NEODAQ", sum(volume)]
    summ[ticker == "NEODAQ", volume := index_volume]
  }

  summ[, change := curr - open]
  summ[, range := high - low]
  summ
}

# Summarize stocks over all time
summarize_all <- function(data) {
  summ <- data[, list(
    curr = curr[.N],
    high = max(curr, na.rm = TRUE),
    time_high = .SD[which.max(curr), time],
    low = min(curr, na.rm = TRUE),
    avg = round(mean(curr, na.rm = TRUE), 1),
    median = as.double(median(curr, na.rm = TRUE)),
    sd = round(sd(curr, na.rm = TRUE), 1)
  ), by = ticker]

  highs <- high_by_day(data)
  summ_day <- highs[, list(pct_95 = round(quantile(curr, 0.95, na.rm = TRUE))), by = ticker]

  peaks <- highs[, .SD[get_peaks(curr)], by = ticker]
  num_days <- highs[curr > 0, list(days = .N), keyby = ticker]
  summ_peaks <- peaks[, list(
    num_peaks = .N,
    avg_peak = round(mean(curr)),
    avg_days_peak = round(num_days[ticker]$days / .N),
    last_peak = suppressWarnings(max(time)),
    med_peak = round(median(curr))
  ), by = ticker]

  summ <- merge(summ, summ_day, on = "ticker", all = TRUE)
  summ <- merge(summ, summ_peaks, on = "ticker", all = TRUE)
  summ
}

# Get price highs by day
high_by_day <- function(data, fill = TRUE) {
  highs <- data[data[, list(.I = .I[which.max(curr)]),
                     by = list(ticker, date = as_date(time))]$.I]

  if (fill) {
    # Fill in missing days
    highs[, date := as_date(time)]
    all_dates <- highs[, list(date = seq(min(date), max(date), by = "days")), by = ticker]
    highs <- highs[all_dates, on = list(date, ticker)]
    highs[is.na(curr), time := as_datetime(format(date))]
    highs[, curr := as.double(curr)][is.na(curr), curr := -Inf]
  }

  highs
}

# Get price peaks by day
peaks_by_day <- function(data) {
  highs <- high_by_day(data)
  peaks <- highs[, .SD[get_peaks(curr)], by = ticker]
  peaks
}

# Find local peaks with min value and range. Returns indices of peaks.
get_peaks <- function(x, days = 30, min_val = 30, threshold = 15) {
  filter_func = function(val, surround) {
    (val >= min_val) && (val - min(surround) >= threshold)
  }
  peaks_ind <- find_peaks(x, m = days / 2, filter_func)
  peaks_ind
}

# Find local peaks, adapted from https://github.com/stas-g/findPeaks
find_peaks <- function (x, m = 3, filter_func = NULL) {
  shape <- diff(sign(diff(x, na.pad = FALSE)))
  maxima <- which(shape < 0) + 1
  # Include tail
  maxima <- c(maxima, length(x))
  pks <- sapply(maxima, function(i) {
    start <- i - m
    start <- max(start, 1)
    end <- i + m
    end <- min(end, length(x))

    val <- x[i]
    left <- x[start:(i-1)]
    right <- x[(i+1):end]
    left <- left[!is.na(left) & left > 0]
    right <- right[!is.na(right) & right > 0]

    if (!is.null(filter_func) && !filter_func(val, c(left, right))) {
      return(numeric(0))
    }

    if (all(c(left < val, right <= val), na.rm = TRUE)) {
      return(i)
    }
  })
  pks <- unlist(pks)
  pks
}

# Summarize market volume (shares bought) by price
summarize_volume_price <- function(data) {
  summ <- data[, list(curr, vol_change = volume_change(volume)), by = ticker]
  summ <- summ[, list(volume = sum(vol_change)), by = curr]
  # Ignore errors (min price is 10 NP, but 9 NP purchases show up occasionally)
  summ[curr <= 9, volume := 0]
  summ <- summ[, pct := round(volume / sum(volume) * 100, 1)][order(curr)]
  summ
}

# Summarize market volume (shares bought) by day
summarize_volume_day <- function(data) {
  summ <- data[, list(volume = total_volume(volume)),
               by = list(date = as_date(time), ticker)]
  summ <- summ[, list(volume = sum(volume)), by = date]
  summ
}

# Calculate volume changes, adjusting for daily resets at
# 8:30 PM and 12:00 AM NST, and anamolous volume resets
# occasionally seen at random times.
volume_change <- function(volume) {
  diff_vol <- diff(volume)
  which_reset <- which(diff_vol < 0)
  diff_vol[which_reset] <- volume[which_reset + 1]
  c(diff_vol, 0)
}

# Calculate total volume, accounting for volume resets
total_volume <- function(volume) {
  sum(volume[1], volume_change(volume))
}
