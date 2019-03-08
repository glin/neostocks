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

test_that("ui_template", {
  template_file <- "data/template.html"

  # Summary only
  stock_data <- list(market_summary = list(price = 5), price_data = NULL)
  html <- ui_template(template_file, stock_data, title = "summary")
  expected <- '<html>
<head>
<meta property="og:title" content="summary - neostocks"/>
<title>summary - neostocks</title>
</head>
<body>
<script>window.__data__ = {"price":5}</script>
</body>
</html>'
  expect_equal(as.character(html), expected)

  # With ticker prices
  stock_data <- list(
    market_summary = list(price = 5),
    price_data = list(
      "1d" = data.table(
        ticker = c("AAVL"),
        time = c(100),
        curr = c(22)
      )
    )
  )
  html <- ui_template(
    template_file,
    stock_data,
    title = "ticker",
    ticker = "AAVL",
    period = "1d"
  )
  expected <- '<html>
<head>
<meta property="og:title" content="ticker - neostocks"/>
<title>ticker - neostocks</title>
</head>
<body>
<script>window.__data__ = {"price":5}</script>
<script>window.__ticker_data__ = {"prices":{"time":[100],"curr":[22]},"ticker":"AAVL","period":"1d"}</script>
</body>
</html>'
  expect_equal(as.character(html), expected)
})

test_that("document_title", {
  expect_equal(document_title(), "neostocks")
  expect_equal(document_title("mypage"), "mypage - neostocks")
  expect_equal(document_title("My Page - 2"), "My Page - 2 - neostocks")
})