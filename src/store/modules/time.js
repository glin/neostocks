import * as types from '../types'

const state = {
  now: new Date()
}

export const actions = {
  [types.TIME_START_TIMER]({ commit }) {
    setInterval(() => commit(types.TIME_TICK_TIMER), 60 * 1000)
  }
}

export const mutations = {
  [types.TIME_TICK_TIMER](state) {
    state.now = new Date()
  }
}

export default {
  state,
  actions,
  mutations
}
