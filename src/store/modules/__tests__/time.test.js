import { mutations, actions } from '../time'
import * as types from '../../types'

jest.useFakeTimers()

describe('mutations', () => {
  test('TIME_TICK_TIMER', () => {
    const now = new Date()
    const originalDate = Date
    global.Date = jest.fn(() => now)
    const state = {}
    mutations[types.TIME_TICK_TIMER](state)
    expect(state).toEqual({ now })
    global.Date = originalDate
  })
})

describe('actions', () => {
  test('TIME_START_TIMER', () => {
    const commit = jest.fn()
    actions[types.TIME_START_TIMER]({ commit })
    expect(setInterval).toHaveBeenCalledTimes(1)
    expect(setInterval).toHaveBeenCalledWith(expect.any(Function), 60 * 1000)
    // Timer updates
    jest.advanceTimersByTime(60 * 1000)
    expect(commit).toHaveBeenCalledTimes(1)
    expect(commit).toHaveBeenCalledWith(types.TIME_TICK_TIMER)
  })
})
