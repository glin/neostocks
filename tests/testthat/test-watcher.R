test_that("FileWatcher detects file changes", {
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

test_that("FileWatcher detects directory changes", {
  d <- tempdir()
  changed <- 0
  handler <- function() changed <<- changed + 1
  watcher <- FileWatcher$new(d, handler, 0.05)
  on.exit(watcher$stop())
  expect_equal(changed, 0)
  watcher$start()

  # Add a file
  f1 <- tempfile(tmpdir = d)
  on.exit(unlink(f1))
  write("1", file = f1)
  Sys.sleep(0.1)
  later::run_now()
  expect_equal(changed, 1)

  # Change a file
  write("1", file = f1)
  Sys.sleep(0.1)
  later::run_now()
  expect_equal(changed, 2)

  # Add another file
  f2 <- tempfile(tmpdir = d)
  on.exit(unlink(f2))
  write("1", file = f2)
  Sys.sleep(0.1)
  later::run_now()
  expect_equal(changed, 3)

  # Remove a file
  unlink(f2)
  Sys.sleep(0.1)
  later::run_now()
  expect_equal(changed, 4)
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
