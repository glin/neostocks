# Create a router from a list of routes
router <- function(routes) {
  if (!is.list(routes) || !all(sapply(routes, is.route))) {
    stop("`routes` must be a list of routes")
  }
  Router$new(routes)
}

# Define a route given a path pattern, handler function, query params
route <- function(path = NULL, handler = NULL, query = NULL) {
  stopifnot(is.null(path) || is.character(path))
  stopifnot(is.null(query) || is.character(query))
  structure(
    list(path = path, handler = handler, query = query),
    class = "route"
  )
}

is.route <- function(x) {
  inherits(x, "route")
}

Router <- R6::R6Class("Router",
  public = list(
    routes = list(),

    initialize = function(routes) {
      self$routes <- routes
    },

    handle = function(req) {
      path <- req$PATH_INFO
      matched <- self$match(path)
      if (is.null(matched)) {
        return(NULL)
      }

      route <- matched$route
      if (!is.function(route$handler)) {
        res <- route$handler
      } else {
        params <- matched$params
        if (!is.null(route$query)) {
          query <- shiny::parseQueryString(req$QUERY_STRING)
          params <- c(params, setNames(query[route$query], route$query))
        }
        res <- call_func(route$handler, as.list(params))
      }

      res
    },

    match = function(path) {
      for (route in self$routes) {
        if (is.null(route$path)) {
          return(list(route = route))
        }
        result <- match_path(path, route$path)
        if (result$matched) {
          return(list(route = route, params = result$params))
        }
      }
    }
  )
)

match_path <- function(path, pattern, sensitive = FALSE, strict = FALSE) {
  re <- path_to_regex(pattern, sensitive = sensitive, strict = strict)
  match <- regexec(re$regex, path, perl = TRUE)
  substrings <- regmatches(path, match)[[1]]
  if (length(substrings) == 0) return(list(matched = FALSE))
  params <- setNames(as.list(substrings[-1]), re$keys)
  list(matched = TRUE, params = params)
}

path_to_regex <- function(path, sensitive = FALSE, strict = FALSE) {
  regex <- path
  keys <- NULL

  key_matches <- gregexpr("/:[^?]([^/]+)", path, perl = TRUE)
  hasKeys <- key_matches[[1]][1] != -1

  if (hasKeys) {
    key_patterns <- regmatches(path, key_matches)[[1]]
    is_optional_key <- substring(key_patterns, nchar(key_patterns)) == "?"
    keys <- substr(key_patterns, 3, nchar(key_patterns) - ifelse(is_optional_key, 1, 0))
    key_regexes <- rep("/([^/]+)", length(key_patterns))
    key_regexes[is_optional_key] <- sprintf("(?:%s)?", key_regexes[is_optional_key])
    regmatches(regex, key_matches) <- list(key_regexes)
  }

  if (!sensitive) {
    regex <- paste0("(?i)", regex)
  }

  if (!strict) {
    regex <- paste0(regex, "(?:/)?")
  }

  regex <- sprintf("^%s$", regex)
  list(regex = regex, keys = keys)
}

call_func <- function(func, args = list()) {
  stopifnot(is.list(args))
  do.call(func, args[names(args) %in% names(formals(func))])
}
