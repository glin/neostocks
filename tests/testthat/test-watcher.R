test_that("FileWatcher works", {
  f <- tempfile()
  on.exit(unlink(f))
  write("1", file = f)
  changed <- 0
  handler <- function() changed <<- changed + 1
  watcher <- FileWatcher$new(f, handler, 0.05)
  on.exit(watcher$stop())
  expect_equal(changed, 0)
  watcher$start()
  Sys.sleep(0.1)
  write("2", file = f)
  Sys.sleep(0.1)
  later::run_now()
  expect_equal(changed, 1)
})

test_that("FileWatcher works when handler returns a promise", {
  f <- tempfile()
  on.exit(unlink(f))
  write("1", file = f)
  changed <- 0
  handler <- function() {
    changed <<- changed + 1
    promises::promise(function(resolve, reject) resolve(TRUE))
  }
  watcher <- FileWatcher$new(f, handler, 0.05)
  on.exit(watcher$stop())
  expect_equal(changed, 0)
  watcher$start()
  Sys.sleep(0.1)
  write("2", file = f)
  Sys.sleep(0.1)
  later::run_now()
  expect_equal(changed, 1)
})

test_that("FileWatcher stops on error", {
  f <- tempfile()
  on.exit(unlink(f))
  write("1", file = f)
  changed <- 0
  handler <- function() {
    changed <<- changed + 1
    promises::promise(function(resolve, reject) reject("handler error"))
  }
  watcher <- FileWatcher$new(f, handler, 0.05)
  on.exit(watcher$stop())
  expect_equal(changed, 0)
  watcher$start()
  Sys.sleep(0.1)
  write("2", file = f)
  Sys.sleep(0.1)
  later::run_now()
  expect_equal(changed, 1)
  later::run_now()
  later::run_now()
  expect_false(watcher$running)
})
