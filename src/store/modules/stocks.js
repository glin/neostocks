import * as types from '../types'
import { addMessageHandler } from '../../shiny'

const state = getStockData(window.__data__)

export const actions = {
  [types.STOCKS_SUBSCRIBE]({ commit }) {
    addMessageHandler('stock-data', data => {
      commit(types.STOCKS_SET_DATA, data)
    })
  }
}

export const mutations = {
  [types.STOCKS_SET_DATA](state, data) {
    const newData = getStockData(data)
    Object.keys(newData).forEach(key => {
      state[key] = newData[key]
    })
  }
}

function getStockData(data = {}) {
  return {
    summaryData: data.summary_data,
    hotStocks: data.hot_stocks,
    daysFrom15: data.days_from_15,
    priceDist: data.price_dist,
    volumeByDay: data.volume_by_day,
    volumeByPrice: data.volume_by_price,
    updateTime: data.update_time
  }
}

export default {
  state,
  actions,
  mutations
}
