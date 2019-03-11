import Vue from 'vue'
import VueRouter from 'vue-router'

import companies from './companies'
import { updateDocumentTitle } from './document'

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
      showUpdateTime: true,
      title: route => {
        switch (route.path) {
          case '/bargain':
            return 'Bargain'
          case '/hot':
            return 'Hot'
        }
        return ''
      }
    }
  },
  {
    path: '/tickers/:ticker',
    component: () => import(/* webpackPrefetch: true */ './components/Ticker'),
    props: route => ({ ticker: route.params.ticker, period: route.query.period }),
    meta: {
      showUpdateTime: true,
      title: route => route.params.ticker
    },
    beforeEnter(to, from, next) {
      if (!companies[to.params.ticker]) {
        to.meta.showUpdateTime = false
        to.meta.title = 'page not found'
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
      showUpdateTime: true,
      title: 'Index'
    }
  },
  {
    path: '/trends',
    component: () => import(/* webpackPrefetch: true */ './components/Trends'),
    meta: {
      showUpdateTime: true,
      title: 'Trends'
    }
  },
  {
    path: '/settings',
    component: () => import('./components/Settings'),
    meta: {
      title: 'Settings'
    }
  },
  {
    path: '/about',
    component: () => import('./components/About'),
    meta: {
      title: 'About'
    }
  },
  {
    path: '/privacy',
    component: () => import('./components/Privacy'),
    meta: {
      title: 'Privacy'
    }
  },
  {
    path: '*',
    component: () => import('./components/PageNotFound'),
    meta: {
      title: 'page not found'
    }
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

  // Update document title
  const title = to.meta.title
  const newPageTitle = typeof title === 'function' ? title(to) : title
  updateDocumentTitle({ newPageTitle })

  next()
})

export default router
