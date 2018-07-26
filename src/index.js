import Vue from 'vue'
import VueRouter from 'vue-router'
import BootstrapVue from 'bootstrap-vue'

import 'bootstrap/dist/css/bootstrap.css'
import 'bootstrap-vue/dist/bootstrap-vue.css'

import App from './App'
import About from './components/About'
import PeriodNav from './components/PeriodNav'
import Summary from './components/Summary'
import Ticker from './components/Ticker'
import MarketIndex from './components/MarketIndex'
import PageNotFound from './components/PageNotFound'

Vue.use(VueRouter)
Vue.use(BootstrapVue)

const routes = [
  {
    path: '/summary',
    alias: ['/', '/bargain', '/hot'],
    components: {
      nav: PeriodNav,
      main: Summary
    },
    props: {
      nav: route => {
        return { period: route.query.period }
      },
      main: route => {
        let filter = route.query.filter
        switch (route.path) {
          case '/bargain':
            filter = 'bargain'
            break
          case '/hot':
            filter = 'hot'
            break
        }
        return { period: route.query.period, filter }
      }
    }
  },
  {
    path: '/tickers/:id',
    components: {
      nav: PeriodNav,
      main: Ticker
    },
    props: {
      nav: route => ({ period: route.query.period }),
      main: route => ({ id: route.params.id, period: route.query.period })
    }
  },
  {
    path: '/index',
    components: {
      nav: PeriodNav,
      main: MarketIndex
    },
    props: {
      nav: route => ({ period: route.query.period }),
      main: route => ({ period: route.query.period })
    }
  },
  {
    path: '/about',
    components: {
      main: About
    }
  },
  {
    path: '*',
    components: {
      main: PageNotFound
    }
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
