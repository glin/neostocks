import * as types from '../types'
import { subscribeToTickerData, selectTicker } from '../../api/stocks'

const state = {
  isLoading: false,
  prices: null,
  peaks: null
}

export const actions = {
  [types.TICKER_SUBSCRIBE]({ commit }) {
    subscribeToTickerData(data => {
      commit(types.TICKER_RECEIVE_DATA, data)
    })
  },
  [types.TICKER_SELECT_TICKER]({ commit }, { ticker, period }) {
    commit(types.TICKER_REQUEST_DATA)
    selectTicker(ticker, period)
  }
}

export const mutations = {
  [types.TICKER_REQUEST_DATA](state) {
    state.isLoading = true
  },
  [types.TICKER_RECEIVE_DATA](state, data) {
    state.prices = data.prices
    state.peaks = data.peaks
    state.isLoading = false
  }
}

export default {
  state,
  actions,
  mutations
}
