import { mutations, actions } from '../stocks'
import * as types from '../../types'
import { subscribeToStockData } from '../../../api/stocks'

jest.mock('../../../api/stocks')

describe('mutations', () => {
  test('STOCKS_SET_DATA', () => {
    const state = { a: 1 }
    const data = { b: 2, c: 3 }
    mutations[types.STOCKS_SET_DATA](state, data)
    expect(state).toEqual({ a: 1, b: 2, c: 3 })
  })
})

describe('actions', () => {
  test('STOCKS_SUBSCRIBE', () => {
    const commit = jest.fn()
    actions[types.STOCKS_SUBSCRIBE]({ commit })
    expect(subscribeToStockData).toHaveBeenCalledWith(expect.any(Function))
    const handler = subscribeToStockData.mock.calls[0][0]
    handler({ data: 246 })
    expect(commit).toHaveBeenCalledTimes(1)
    expect(commit).toHaveBeenCalledWith(types.STOCKS_SET_DATA, { data: 246 })
  })
})
