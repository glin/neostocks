import {
  getInitialStockData,
  subscribeToStockData,
  subscribeToTickerData,
  getInitialTickerData,
  selectTicker,
  setLastUpdate
} from '../stocks'
import { addMessageHandler, setInputValue } from '../shiny'

jest.mock('../shiny')

afterEach(() => {
  jest.clearAllMocks()
})

describe('stocks', () => {
  const data = {
    summary_data: { period_1d: [{ curr: 1 }] },
    hot_stocks: [{ ticker: 'a' }, { ticker: 'b' }],
    days_from_15: [{ curr: 30 }],
    price_dist: [{ curr: 10 }],
    volume_by_day: [{ volume: 20 }],
    volume_by_price: [{ curr: 5 }],
    update_time: { NST: 1 }
  }

  const expected = {
    summaryData: data.summary_data,
    hotStocks: data.hot_stocks,
    daysFrom15: data.days_from_15,
    priceDist: data.price_dist,
    volumeByDay: data.volume_by_day,
    volumeByPrice: data.volume_by_price,
    updateTime: data.update_time
  }

  test('getInitialStockData', () => {
    window.__data__ = data
    expect(getInitialStockData()).toEqual(expected)
  })

  test('subscribeToStockData', () => {
    const handler = jest.fn()
    subscribeToStockData(handler)
    expect(addMessageHandler).toHaveBeenCalledWith('stock_data', expect.any(Function))

    const msgHandler = addMessageHandler.mock.calls[0][1]
    msgHandler(data)
    expect(handler).toHaveBeenCalledTimes(1)
    expect(handler).toHaveBeenCalledWith(expected)
  })
})

describe('ticker', () => {
  test('getInitialTickerData', () => {
    window.__ticker_data__ = { prices: [1, 2, 3], peaks: [4, 5, 6]}
    expect(getInitialTickerData()).toEqual({ prices: [1, 2, 3], peaks: [4, 5, 6]})
    window.__ticker_data__ = undefined
    expect(getInitialTickerData()).toBeNull()
  })

  test('selectTicker', () => {
    selectTicker('BUZZ', '1d')
    expect(setInputValue).toHaveBeenCalledTimes(1)
    expect(setInputValue).toHaveBeenCalledWith('ticker', { ticker: 'BUZZ', period: '1d' })
  })

  test('subscribeToTickerData', () => {
    const handler = jest.fn()
    subscribeToTickerData(handler)
    expect(addMessageHandler).toHaveBeenCalledWith('ticker_data', expect.any(Function))

    const data = {
      prices: { a: [1] },
      peaks: [3, 4]
    }
    const msgHandler = addMessageHandler.mock.calls[0][1]
    msgHandler(data)
    expect(handler).toHaveBeenCalledTimes(1)
    expect(handler).toHaveBeenCalledWith(data)
  })
})

test('setLastUpdate', () => {
  setLastUpdate('tuesday')
  expect(setInputValue).toHaveBeenCalledTimes(1)
  expect(setInputValue).toHaveBeenCalledWith('last_update', { time: 'tuesday' })
})
