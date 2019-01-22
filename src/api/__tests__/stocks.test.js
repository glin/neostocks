import { getInitialStockData, subscribeToStockData } from '../stocks'
import { addMessageHandler } from '../shiny'

jest.mock('../shiny')

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
  expect(addMessageHandler).toHaveBeenCalledWith('stock-data', expect.any(Function))
  const rawHandler = addMessageHandler.mock.calls[0][1]
  rawHandler(data)
  expect(handler).toHaveBeenCalledTimes(1)
  expect(handler).toHaveBeenCalledWith(expected)
})
