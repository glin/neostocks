import * as types from '../types'
import { getInitialStockData, subscribeToStockData } from '../../api/stocks'

const state = getInitialStockData()

export const actions = {
  [types.STOCKS_SUBSCRIBE]({ commit }) {
    subscribeToStockData(data => {
      commit(types.STOCKS_SET_DATA, data)
    })
  }
}

export const mutations = {
  [types.STOCKS_SET_DATA](state, data) {
    Object.keys(data).forEach(key => {
      state[key] = data[key]
    })
  }
}

export default {
  state,
  actions,
  mutations
}
