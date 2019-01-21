import Vue from 'vue'
import Vuex from 'vuex'

import stocks from './modules/stocks'
import time from './modules/time'

Vue.use(Vuex)

const isDebug = process.env.NODE_ENV !== 'production'

export default new Vuex.Store({
  modules: {
    stocks,
    time
  },
  strict: isDebug
})
