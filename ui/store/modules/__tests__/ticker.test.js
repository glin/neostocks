import { mutations, actions } from '../ticker'
import * as types from '../../types'
import { subscribeToTickerData, selectTicker } from '../../../api/stocks'

jest.mock('../../../api/stocks')

describe('mutations', () => {
  test('TICKER_REQUEST_DATA', () => {
    const initialState = { prices: 1, firstLoad: true }
    mutations[types.TICKER_REQUEST_DATA](initialState)
    expect(initialState).toEqual({ prices: 1, firstLoad: true })

    const state = { prices: 1, firstLoad: false }
    mutations[types.TICKER_REQUEST_DATA](state)
    expect(state).toEqual({ prices: null, firstLoad: false })
  })

  test('TICKER_RECEIVE_DATA', () => {
    const state = { prices: null, peaks: null, firstLoad: true }
    mutations[types.TICKER_RECEIVE_DATA](state, { prices: 1, peaks: 2 })
    expect(state).toEqual({ prices: 1, peaks: 2, firstLoad: false })
  })
})

describe('actions', () => {
  test('TICKER_SELECT_TICKER', () => {
    const commit = jest.fn()
    actions[types.TICKER_SELECT_TICKER]({ commit }, { ticker: 'BOOM', period: '5d' })
    expect(selectTicker).toHaveBeenCalledWith('BOOM', '5d')
    expect(commit).toHaveBeenCalledTimes(1)
    expect(commit).toHaveBeenCalledWith(types.TICKER_REQUEST_DATA)
  })

  test('TICKER_SUBSCRIBE', () => {
    const commit = jest.fn()
    actions[types.TICKER_SUBSCRIBE]({ commit }, { ticker: 'BOOM', period: '5d' })
    expect(selectTicker).toHaveBeenCalledWith('BOOM', '5d')
    const handler = subscribeToTickerData.mock.calls[0][0]
    handler({ data: 246 })
    expect(commit).toHaveBeenCalledTimes(1)
    expect(commit).toHaveBeenCalledWith(types.TICKER_RECEIVE_DATA, { data: 246 })
  })
})
