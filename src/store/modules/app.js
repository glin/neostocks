import * as types from '../types'

const state = {
  now: new Date(),
  isTouchCapable: false
}

export const getters = {
  query(state, getters, rootState) {
    if (rootState.route.query.period) {
      return { period: rootState.route.query.period }
    }
    return null
  }
}

export const actions = {
  [types.APP_TIMER_START]({ commit }) {
    setInterval(() => commit(types.APP_TIMER_TICK), 60 * 1000)
  },
  [types.APP_SET_TOUCH_CAPABLE]({ commit }, isTouchCapable) {
    commit(types.APP_SET_TOUCH_CAPABLE, isTouchCapable)
  }
}

export const mutations = {
  [types.APP_TIMER_TICK](state) {
    state.now = new Date()
  },
  [types.APP_SET_TOUCH_CAPABLE](state, isTouchCapable) {
    state.isTouchCapable = isTouchCapable
  }
}

export default {
  state,
  getters,
  actions,
  mutations
}
