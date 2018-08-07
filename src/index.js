import Vue from 'vue'
import VueRouter from 'vue-router'
import BootstrapVue from 'bootstrap-vue'

import 'bootstrap/dist/css/bootstrap.css'
import 'bootstrap-vue/dist/bootstrap-vue.css'

import App from './App'
import About from './components/About'
import Summary from './components/Summary'
import Ticker from './components/Ticker'
import PageNotFound from './components/PageNotFound'

Vue.use(VueRouter)
Vue.use(BootstrapVue)

const routes = [
  {
    path: '/summary',
    alias: ['/', '/bargain', '/hot'],
    component: Summary,
    props: route => {
      let filter = route.query.filter
      switch (route.path) {
        case '/bargain':
          filter = 'bargain'
          break
        case '/hot':
          filter = 'hot'
          break
      }
      return { period: route.query.period, search: route.query.search, filter }
    }
  },
  {
    path: '/tickers/:ticker',
    component: Ticker,
    props: route => ({ ticker: route.params.ticker, period: route.query.period })
  },
  {
    path: '/index',
    alias: '/tickers/NEODAQ',
    component: Ticker,
    props: route => ({ ticker: 'NEODAQ', period: route.query.period })
  },
  {
    path: '/about',
    component: About
  },
  {
    path: '*',
    component: PageNotFound
  }
]

const router = new VueRouter({
  routes,
  mode: 'history',
  caseSensitive: false
})

router.beforeEach((to, from, next) => {
  // Convert all query parameters to lowercase
  Object.keys(to.query).map(key => {
    if (key === 'search') return
    to.query[key] = to.query[key].toLowerCase()
  })
  next()
})

// Vue.config.devtools = true

new Vue({
  el: '#app',
  router,
  render: h => h(App)
})
