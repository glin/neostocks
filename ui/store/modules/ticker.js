import * as types from '../types'
import { getInitialTickerData, subscribeToTickerData, selectTicker } from '../../api/stocks'

const state = {
  prices: null,
  peaks: null,
  ...getInitialTickerData()
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
    state.prices = null
  },
  [types.TICKER_RECEIVE_DATA](state, data) {
    state.prices = data.prices
    state.peaks = data.peaks
  }
}

export default {
  state,
  actions,
  mutations
}
