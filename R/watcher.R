# Watches for file or directory changes in the background
FileWatcher <- R6::R6Class(
  "FileWatcher",
  public = list(
    path = NULL,
    change_handler = NULL,
    interval_sec = 0,
    running = FALSE,
    mtimes = NULL,

    initialize = function(path, change_handler, interval_sec) {
      self$path <- path
      self$change_handler <- change_handler
      self$interval_sec <- interval_sec
      self$mtimes <- file_mtimes(path)
    },

    start = function() {
      if (self$running) return()
      self$running <- TRUE
      self$watch()
    },

    stop = function() {
      self$running <- FALSE
    },

    watch = function() {
      if (!self$running) return()
      mtimes <- file_mtimes(self$path)
      if (!identical(mtimes, self$mtimes)) {
        self$mtimes <- mtimes
        result <- self$change_handler()
        # Ensure async handlers run one at a time
        if (is.promise(result)) {
          result %>% then(self$watch) %>% catch(function(e) {
            self$stop()
            stop("FileWatcher handler error: ", e$message)
          })
          return()
        }
      }
      later::later(self$watch, self$interval_sec)
    }
  )
)

file_mtimes <- function(path) {
  files <- if (is_directory(path)) {
    dir(path, full.names = TRUE)
  } else {
    path
  }
  files <- normalizePath(files, winslash = "/", mustWork = TRUE)
  mtimes <- stats::setNames(file.info(files)$mtime, files)
}

is_directory <- function(path) {
  isTRUE(file.info(path)$isdir)
}
