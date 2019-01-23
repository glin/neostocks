import { addMessageHandler, setInputValue } from './shiny'

export function getInitialStockData() {
  return getStockData(window.__data__)
}

export function subscribeToStockData(handler) {
  addMessageHandler('stock_data', data => {
    handler(getStockData(data))
  })
}

function getStockData(data) {
  return {
    summaryData: data.summary_data,
    hotStocks: data.hot_stocks,
    daysFrom15: data.days_from_15,
    priceDist: data.price_dist,
    volumeByDay: data.volume_by_day,
    volumeByPrice: data.volume_by_price,
    updateTime: data.update_time
  }
}

export function subscribeToTickerData(handler) {
  addMessageHandler('ticker_data', data => {
    handler(getTickerData(data))
  })
}

export function selectTicker(ticker, period) {
  setInputValue('ticker', { ticker, period })
}

function getTickerData(data) {
  return {
    prices: data.prices,
    peaks: data.peaks
  }
}
