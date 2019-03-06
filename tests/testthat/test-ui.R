context("ui")

test_that("ticker_page", {
  expect_equal(ticker_page("AAVL", "5d"), list(
    title = "AAVL",
    ticker = "AAVL",
    period = "5d"
  ))

  expect_equal(ticker_page("BOOM", "1d"), not_found_page)
})

test_that("index_page", {
  expect_equal(index_page("5d"), list(
    title = "Index",
    ticker = "NEODAQ",
    period = "5d"
  ))
})

test_that("document_title", {
  expect_equal(document_title(), "neostocks")
  expect_equal(document_title("mypage"), "mypage - neostocks")
  expect_equal(document_title("My Page - 2"), "My Page - 2 - neostocks")
})
