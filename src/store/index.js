import Vue from 'vue'
import Vuex from 'vuex'

import * as types from './types'
import stocks from './modules/stocks'

Vue.use(Vuex)

const isDebug = process.env.NODE_ENV !== 'production'

const state = {
  now: new Date()
}

export const actions = {
  [types.TIMER_START]({ commit }) {
    setInterval(() => commit(types.TIMER_TICK), 60 * 1000)
  }
}

export const mutations = {
  [types.TIMER_TICK](state) {
    state.now = new Date()
  }
}

export default new Vuex.Store({
  state,
  actions,
  mutations,
  modules: {
    stocks
  },
  strict: isDebug
})
