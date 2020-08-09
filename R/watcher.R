# Watches for file changes in the background
FileWatcher <- R6::R6Class(
  "FileWatcher",
  public = list(
    file = NULL,
    change_handler = NULL,
    interval_sec = 0,
    running = FALSE,
    mtime = NULL,

    initialize = function(file, change_handler, interval_sec) {
      self$file <- file
      self$change_handler <- change_handler
      self$interval_sec <- interval_sec
      self$mtime <- file.mtime(file)
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
      mtime <- file.mtime(self$file)
      if (!identical(mtime, self$mtime)) {
        self$mtime <- mtime
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
