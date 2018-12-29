import Vue from 'vue'
import VueRouter from 'vue-router'

import 'bootstrap/dist/css/bootstrap.css'
import 'bootstrap-vue/dist/bootstrap-vue.css'

import App from './App'
import companies from './companies'

Vue.use(VueRouter)

const routes = [
  {
    path: '/summary',
    alias: ['/', '/bargain', '/hot'],
    component: () => import(/* webpackPrefetch: true */ './components/Summary'),
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
    },
    meta: {
      showUpdateTime: true
    }
  },
  {
    path: '/tickers/:ticker',
    component: () => import(/* webpackPrefetch: true */ './components/Ticker'),
    props: route => ({ ticker: route.params.ticker, period: route.query.period }),
    meta: {
      showUpdateTime: true
    },
    beforeEnter(to, from, next) {
      if (!companies[to.params.ticker]) {
        to.meta.showUpdateTime = false
      }
      next()
    }
  },
  {
    path: '/index',
    alias: '/tickers/NEODAQ',
    component: () => import(/* webpackPrefetch: true */ './components/Ticker'),
    props: route => ({ ticker: 'NEODAQ', period: route.query.period }),
    meta: {
      showUpdateTime: true
    }
  },
  {
    path: '/trends',
    component: () => import(/* webpackPrefetch: true */ './components/Trends'),
    meta: {
      showUpdateTime: true
    }
  },
  {
    path: '/settings',
    component: () => import(/* webpackPrefetch: true */ './components/Settings')
  },
  {
    path: '/about',
    component: () => import('./components/About')
  },
  {
    path: '*',
    component: () => import('./components/PageNotFound')
  }
]

const router = new VueRouter({
  routes,
  mode: 'history',
  caseSensitive: false
})

router.beforeEach((to, from, next) => {
  // Clean up query params
  Object.keys(to.query).map(key => {
    if (key === 'search') return
    if (key === 'period') {
      to.query.period = to.query.period.toLowerCase()
      if (!['1d', '5d', '1m', 'all'].includes(to.query.period)) {
        to.query.period = '1d'
      }
    }
  })
  next()
})

new Vue({
  el: '#app',
  router,
  render: h => h(App)
})
