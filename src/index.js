import Vue from 'vue'
import { sync } from 'vuex-router-sync'

import App from './App'
import router from './router'
import store from './store'

sync(store, router)

new Vue({
  router,
  store,
  render: h => h(App)
}).$mount('#app')
