request <- function(path = "/", query = NULL) {
  list(PATH_INFO = path, QUERY_STRING = query)
}

test_that("new router", {
  expect_error(router("not list"), "must be a list of routes")
  expect_error(router(list(1, 2, "not route")), "must be a list of routes")
  expect_error(router(list(route(), "not route")), "must be a list of routes")

  r <- router(list(route("/", function() {})))
  expect_true(inherits(r, "Router"))
})

test_that("router handles matching paths", {
  r <- router(list(
    route("/a", function() "a"),
    route("/b", "b"),
    route("/a/:id", function(id) id),
    route("/a/:id/:name", function(id, name, x) c(id, name)),
    route(handler = function() 404)
  ))

  expect_equal(r$handle(request("/a")), "a")
  expect_equal(r$handle(request("/b")), "b")
  expect_equal(r$handle(request("/a/55")), "55")
  expect_equal(r$handle(request("/a/23/pq")), c("23", "pq"))
  expect_equal(r$handle(request("/notfound")), 404)
})

test_that("router handles no matching paths", {
  r <- router(list(
    route("/a", function() "a")
  ))
  expect_null(r$handle(request("/notfound")))
})

test_that("router handles query params", {
  r <- router(list(
    route("/a", function() "a"),
    route("/a/:id", function(id, name) list(id, name), query = "name"),
    route("/a/:id/:name", function(id, name) c(id, name)),
    route("/b", function(id, name) paste(id, name), query = c("id", "name"))
  ))

  expect_equal(r$handle(request("/a/55")), list("55", NULL))
  expect_equal(r$handle(request("/a/55", "?name=al")), list("55", "al"))
  expect_equal(r$handle(request("/a/23/pq")), c("23", "pq"))
  expect_equal(r$handle(request("/b", "?name=1&k=2&id=a")), "a 1")
})
