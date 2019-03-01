import Vue from 'vue'
import Vuex from 'vuex'

import app from './modules/app'
import stocks from './modules/stocks'
import ticker from './modules/ticker'

Vue.use(Vuex)

const isDebug = process.env.NODE_ENV !== 'production'

export default new Vuex.Store({
  modules: {
    app,
    stocks,
    ticker
  },
  strict: isDebug
})
