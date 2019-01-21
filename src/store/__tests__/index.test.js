import { mutations, actions } from '..'
import * as types from '../types'

jest.useFakeTimers()

describe('mutations', () => {
  test('TIMER_TICK', () => {
    const now = new Date()
    const originalDate = Date
    global.Date = jest.fn(() => now)
    const state = {}
    mutations[types.TIMER_TICK](state)
    expect(state).toEqual({ now })
    global.Date = originalDate
  })
})

describe('actions', () => {
  test('TIMER_START', () => {
    const commit = jest.fn()
    actions[types.TIMER_START]({ commit })
    expect(setInterval).toHaveBeenCalledTimes(1)
    expect(setInterval).toHaveBeenCalledWith(expect.any(Function), 60 * 1000)
    // Timer updates
    jest.advanceTimersByTime(60 * 1000)
    expect(commit).toHaveBeenCalledTimes(1)
    expect(commit).toHaveBeenCalledWith(types.TIMER_TICK)
  })
})
