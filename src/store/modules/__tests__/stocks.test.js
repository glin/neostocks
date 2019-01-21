import { mutations, actions } from '../stocks'
import * as types from '../../types'
import { addMessageHandler } from '../../../shiny'

jest.mock('../../../shiny')

describe('mutations', () => {
  test('STOCKS_SET_DATA', () => {
    const state = {}
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
    mutations[types.STOCKS_SET_DATA](state, data)
    expect(state).toEqual(expected)
  })
})

describe('actions', () => {
  test('STOCKS_SUBSCRIBE', () => {
    const commit = jest.fn()
    actions[types.STOCKS_SUBSCRIBE]({ commit })
    expect(addMessageHandler).toHaveBeenCalledWith('stock-data', expect.any(Function))

    const handler = addMessageHandler.mock.calls[0][1]
    const data = { data: 246 }
    handler(data)
    expect(commit).toHaveBeenCalledTimes(1)
    expect(commit).toHaveBeenCalledWith(types.STOCKS_SET_DATA, data)
  })
})
