# Predict stock prices based on historical data:
#   - Long-term distribution
#   - Expected days to reach from 15 NP
predict_prices <- function(data) {
  tm <- build_price_model(data)
  steady_states <- calc_steady_states(tm) * 100

  curr <- as.numeric(rownames(tm))
  predicted <- data.table(curr = curr, p = steady_states)

  expected_days_15 <- sapply(curr[curr > 15], function(x) {
    as.numeric(calc_expected_steps(tm, x)["15"] / 48)
  })
  predicted[curr > 15, days_from_15 := round(expected_days_15)]
  predicted
}

# Build Markov model of stock price changes
build_price_model <- function(data, curr_max = 150) {
  changes <- get_price_changes(data)
  dists <- generate_probability_dists(changes)
  tm <- generate_transition_matrix(dists)
  n <- which(as.numeric(rownames(tm)) == curr_max)
  tm <- tm[1:n, 1:n]
  tm <- pad_transition_matrix(tm)
  tm
}

get_price_changes <- function(data) {
  changes <- data[, list(
    time = time[-length(time)],
    change = diff(curr),
    curr = curr[-length(curr)]
  ), by = ticker]

  # Remove gaps (significantly longer than 30 mins)
  times <- unique(data$time)
  gap_times <- times[which(diff(times) > 32)]
  changes <- changes[!time %in% gap_times]

  # Remove outliers
  changes <- changes[-c(
    which(curr >= 7 & curr <= 20 & abs(change) >= 2),
    which(curr >= 21 & curr <= 40 & abs(change) >= 3),
    which(curr >= 41 & curr <= 60 & abs(change) >= 4),
    which(curr >= 61 & curr <= 100 & abs(change) >= 6),
    which(curr >= 101 & curr <= 150 & abs(change) >= 4),
    which(curr >= 151 & curr <= 200 & abs(change) >= 5),
    which(curr >= 201 & curr <= 250 & abs(change) >= 6),
    which(curr >= 251 & curr <= 300 & abs(change) >= 7),
    which(curr >= 301 & curr <= 350 & abs(change) >= 8)
  )]
}

generate_probability_dists <- function(changes) {
  curr_breaks <- c(6, 7, 8, 9, 10, 21, 41, 61, 101, 151, 201, 251, 301, 351)
  dists <- list()
  for (i in seq.int(1, length(curr_breaks) - 1)) {
    min <- curr_breaks[i]
    max <- curr_breaks[i + 1] - 1
    change <- changes[curr >= min & curr <= max]
    dist <- list(min = min, max = max, dist = calc_probabilities(change))
    dists <- c(dists, list(dist))
  }
  setNames(dists, curr_breaks[-length(curr_breaks)])
}

calc_probabilities <- function(changes) {
  counts <- table(changes$change)
  prob <- counts / sum(counts)
  data.frame(change = as.numeric(names(prob)), p = as.numeric(prob))
}

generate_transition_matrix <- function(dists) {
  curr_min <- min(sapply(dists, function(d) d$min))
  curr_max <- max(sapply(dists, function(d) d$max))
  curr_states <- seq.int(curr_min, curr_max)

  tm <- matrix(0, nrow = length(curr_states), ncol = length(curr_states))
  rownames(tm) <- colnames(tm) <- curr_states

  for (dist in dists) {
    for (curr in seq.int(dist$min, dist$max)) {
      mapply(function(change, p) {
        offset <- curr_min - 1
        next_curr <- curr + change - offset
        if (next_curr <= ncol(tm)) {
          tm[curr - offset, next_curr] <<- p
        }
      }, dist$dist$change, dist$dist$p)
    }
  }

  tm
}

pad_transition_matrix <- function(tm) {
  # Pad incomplete rows with 0 change transitions
  incomplete_rows <- which(rowSums(tm) < 1)
  for (i in incomplete_rows) {
    tm[i, i] <- tm[i, i] + (1 - sum(tm[i, ]))
  }
  tm
}

# Calculate the steady state distribution
# Adapted from https://nicolewhite.github.io/2014/06/10/steady-state-transition-matrix.html
calc_steady_states <- function(tm) {
  n <- ncol(tm)
  A <- t(tm - diag(n))
  A <- rbind(A, rep(1, n))
  b <- c(rep(0, n), 1)
  qr.solve(A, b)
}

# Calculate expected number of steps to a final state
calc_expected_steps <- function(tm, final_state) {
  n_final <- which(rownames(tm) == as.character(final_state))
  n <- n_final - 1
  qm <- tm[seq_len(n), seq_len(n)]
  nm <- solve(diag(n) - qm)
  rowSums(nm)
}
