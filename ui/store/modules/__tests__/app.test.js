import { getters, mutations, actions } from '../app'
import * as types from '../../types'

jest.useFakeTimers()

describe('getters', () => {
  test('query', () => {
    let route = { query: { period: '5d' } }
    let query = getters.query(null, null, { route })
    expect(query).toEqual({ period: '5d' })

    route = { query: {} }
    query = getters.query(null, null, { route })
    expect(query).toBeNull()
  })
})

describe('mutations', () => {
  test('APP_TIMER_TICK', () => {
    const now = new Date()
    const originalDate = Date
    global.Date = jest.fn(() => now)
    const state = {}
    mutations[types.APP_TIMER_TICK](state)
    expect(state).toEqual({ now })
    global.Date = originalDate
  })

  test('APP_SET_TOUCH_CAPABLE', () => {
    const state = { isTouchCapable: false }
    mutations[types.APP_SET_TOUCH_CAPABLE](state, true)
    expect(state).toEqual({ isTouchCapable: true })
  })
})

describe('actions', () => {
  test('APP_TIMER_START', () => {
    const commit = jest.fn()
    actions[types.APP_TIMER_START]({ commit })
    expect(setInterval).toHaveBeenCalledTimes(1)
    expect(setInterval).toHaveBeenCalledWith(expect.any(Function), 60 * 1000)
    // Timer updates
    jest.advanceTimersByTime(60 * 1000)
    expect(commit).toHaveBeenCalledTimes(1)
    expect(commit).toHaveBeenCalledWith(types.APP_TIMER_TICK)
  })

  test('APP_SET_TOUCH_CAPABLE', () => {
    const commit = jest.fn()
    actions[types.APP_SET_TOUCH_CAPABLE]({ commit }, true)
    expect(commit).toHaveBeenCalledTimes(1)
    expect(commit).toHaveBeenCalledWith(types.APP_SET_TOUCH_CAPABLE, true)
  })
})
