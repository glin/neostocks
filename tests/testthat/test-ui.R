test_that("ticker_page", {
  expect_equal(ticker_page("AAVL", "5d"), list(
    title = "AAVL",
    description = "Real-time stock quote and historical prices for AAVL - Alien Aisha Vending Ltd.",
    ticker = "AAVL",
    period = "5d"
  ))

  expect_equal(ticker_page("BOOM", "1d"), not_found_page)
})

test_that("index_page", {
  expect_equal(index_page("5d"), list(
    title = "Neodaq Index",
    description = "The Neodaq Index - how well the stock market is doing as a whole.",
    ticker = "NEODAQ",
    period = "5d"
  ))
})

test_that("new_ui", {
  template_file <- "data/template.html"
  stock_data <- reactiveVal(list(market_summary = list(price = 5), price_data = NULL))

  ui <- new_ui(template_file, stock_data)
  expect_true(is.function(ui))

  expected_html <- function(title = NULL, description = NULL, ticker = NULL) {
    title <- document_title(title)
    if (is.null(description)) {
      description <- home_page$description
    }
    if (!is.null(ticker)) {
      ticker_script <- "\n<script>window.__ticker_data__ = null</script>"
    } else {
      ticker_script <- ""
    }
    sprintf('<html>
<head>
<meta property="og:title" content="%s"/>
<meta name="description" content="%s"/>
<meta property="og:description" content="%s"/>
<title>%s</title>
</head>
<body>
<script>window.__data__ = {"price":5}</script>%s
</body>
</html>', title, description, description, title, ticker_script)
  }

  test_cases <- list(
    list(path = "/"),
    list(path = "/bargain", page = bargain_page),
    list(path = "/hot", page = hot_page),
    list(path = "/trends", page = trends_page),
    list(path = "/settings", page = settings_page),
    list(path = "/about", page = about_page),
    list(path = "/privacy", page = privacy_page),
    list(path = "/tickers/VPTS", page = ticker_page("VPTS", "1d")),
    list(path = "/index", page = index_page("1d")),
    list(path = "/doesntexist", page = not_found_page, status = 404),
    list(path = "/tickers/BOOM", page = not_found_page, status = 404)
  )
  for (test in test_cases) {
    expected <- expected_html(
      title = test$page$title,
      description = test$page$description,
      ticker = test$page$ticker
    )
    if (!is.null(test$status)) {
      resp <- ui(list(PATH_INFO = test$path))
      expect_equal(resp$status, test$status)
      expect_equal(as.character(resp$content), expected)
    } else {
      html <- ui(list(PATH_INFO = test$path))
      expect_equal(as.character(html), expected)
    }
  }
})

test_that("ui_template", {
  template_file <- "data/template.html"

  # Summary only
  stock_data <- list(market_summary = list(price = 5), price_data = NULL)
  html <- ui_template(template_file, stock_data, title = "summary")
  expected <- '<html>
<head>
<meta property="og:title" content="summary - neostocks"/>
<meta name="description" content="Real-time stock tracker for the Neopets Stock Market. Explore stock history, get price alerts, and find the best stocks to buy and sell."/>
<meta property="og:description" content="Real-time stock tracker for the Neopets Stock Market. Explore stock history, get price alerts, and find the best stocks to buy and sell."/>
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
    description = "not BOOM",
    ticker = "AAVL",
    period = "1d"
  )
  expected <- '<html>
<head>
<meta property="og:title" content="ticker - neostocks"/>
<meta name="description" content="not BOOM"/>
<meta property="og:description" content="not BOOM"/>
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
