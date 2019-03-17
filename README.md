# neostocks <a href="https://neostocks.info"><img src="public/neostocks.png" align="right" /></a>

[![Build Status](https://travis-ci.com/glin/neostocks.svg?branch=master)](https://travis-ci.com/glin/neostocks)
[![codecov](https://codecov.io/gh/glin/neostocks/branch/master/graph/badge.svg)](https://codecov.io/gh/glin/neostocks)

[neostocks](https://neostocks.info) is a real-time dashboard for the Neopets Stock Market, similar to the former NeoDaq.com (RIP).

## Getting Started

### Prerequisites
- [R](https://www.r-project.org/) >= 3.1
- [Node.js](https://nodejs.org) LTS or later

### Installation
Clone the repo:
```sh
git clone https://github.com/glin/neostocks
cd neostocks/
```

Install the R package:
```r
# install.packages("devtools")
devtools::install()
```

Build the UI:
```sh
npm install
npm run build
```

### Running
```r
shiny::runApp()
```

To use custom stock data, set the `NEOSTOCKS_DATA_FILE` environment variable:

```sh
# .Renviron
NEOSTOCKS_DATA_FILE=/path/to/neostocks.csv
```

## Development
Build the UI for development:
```sh
npm run dev
npm run dev:watch  # rebuild on changes
```

Run UI tests:
```sh
npm test
npm run test:cover  # with coverage
npm run test:watch  # rerun on changes
```

Run R tests:
```r
devtools::test()
```

## License
MIT