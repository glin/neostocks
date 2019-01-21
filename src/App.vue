<template>
  <div class="main">
    <div class="main-container">
      <Header
        :search="search"
        :search-results="searchResults"
        :on-search-change="handleSearchChange"
        :on-search-submit="handleSearchSubmit"
        :notifications="notifications"
        :on-notifications-read="handleNotificationsRead"
        :has-alerts-created="hasAlertsCreated"
        :query="query"
        :is-touch-capable="isTouchCapable"
      />
      <b-container class="main-content">
        <keep-alive>
          <router-view
            :companies="companies"
            :settings="settings"
            :on-settings-change="handleSettingsChange"
            :query="query"
            :is-touch-capable="isTouchCapable"
          />
        </keep-alive>
      </b-container>
      <UpdateTime v-if="showUpdateTime" />
    </div>
    <Footer />
  </div>
</template>

<style>
html,
body {
  height: 100%;
  overflow: hidden;
}

body {
  overflow-y: scroll;
  background-color: #f7f7f7 !important;
  font-family: 'Open Sans', system-ui, Arial, sans-serif;
}

#shiny-disconnected-overlay,
#ss-overlay,
.ss-reconnecting {
  display: none !important;
}
</style>

<style scoped>
.main {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.main-container {
  flex: 1 0 auto;
  margin-top: 3.5rem;
  margin-bottom: 1.5rem;
}

.main-content {
  margin-top: 15px;
  padding: 0;
}

@media (max-width: 575.98px) {
  .main-container {
    min-height: 100vh;
  }

  .main-content {
    margin-top: 0;
  }
}
</style>

<script>
import { mapState } from 'vuex'
import bContainer from 'bootstrap-vue/es/components/layout/container'

import 'bootstrap/dist/css/bootstrap.css'
import 'bootstrap-vue/dist/bootstrap-vue.css'

import Header from './components/Header'
import Footer from './components/Footer'
import UpdateTime from './components/UpdateTime'
import * as types from './store/types'
import companies from './companies'
import { getSettingsStore } from './settings'
import { notificationsEnabled, requestPermission, swNotificationsSupported } from './notifications'
import { getPriceAlerts, isValidRule, sendNotifications } from './alerts'
import { DAY } from './date'
import { updateDocumentTitle } from './document'

export default {
  components: {
    bContainer,
    Header,
    Footer,
    UpdateTime
  },

  data() {
    return {
      search: '',
      settings: {},
      notifications: [],
      isTouchCapable: false,
      companies
    }
  },

  computed: {
    searchResults() {
      if (!this.search) return []

      const searchItems = this.search
        .split(/[\s,]/)
        .filter(s => s != '')
        .map(s => s.toUpperCase())

      const tickers = Object.keys(this.companies).filter(ticker => {
        const company = this.companies[ticker]
        if (company.index) return false
        return searchItems.some(search => ticker.match(search))
      })

      return tickers.map(ticker => {
        return {
          ticker,
          ...this.companies[ticker],
          location: { path: '/tickers/' + ticker, query: this.query }
        }
      })
    },
    showUpdateTime() {
      return this.$route.meta.showUpdateTime
    },
    hasUnreadNotifications() {
      return this.notifications.some(item => !item.isRead)
    },
    hasAlertsCreated() {
      return this.settings.alerts.some(rule => isValidRule(rule))
    },
    query() {
      const query = {}
      if (this.$route.query.period) {
        query.period = this.$route.query.period
      }
      return query
    },
    ...mapState({
      summaryData: state => state.stocks.summaryData,
      now: state => state.now
    })
  },

  watch: {
    summaryData() {
      const notifications = this.updateNotifications()
      this.sendNotifications(notifications)
    },
    now() {
      this.notifications = this.notifications.filter(item => {
        return this.now - new Date(item.updateTime) <= DAY * 5
      })
    },
    hasUnreadNotifications() {
      this.updateUnreadIndicator()
    }
  },

  created() {
    this.$store.dispatch(types.STOCKS_SUBSCRIBE)
    this.$store.dispatch(types.TIMER_START)

    this.loadSettings()
    this.updateNotifications()

    if (swNotificationsSupported()) {
      navigator.serviceWorker.register('/sw.js')
      navigator.serviceWorker.addEventListener('message', event => {
        if (event.data.readNotifications) {
          this.handleNotificationsRead()
        }
      })
    }

    const onFirstTouch = () => {
      this.isTouchCapable = true
      document.removeEventListener('touchstart', onFirstTouch, false)
    }
    document.addEventListener('touchstart', onFirstTouch, false)
  },

  methods: {
    handleSearchChange(value) {
      this.search = value
    },
    handleSearchSubmit() {
      const query = { search: this.search, ...this.query }
      this.$router.push({ path: '/', query })
    },
    handleSettingsChange(value) {
      Object.keys(value).forEach(key => {
        if (key === 'enableDesktopNotifications' && value.enableDesktopNotifications) {
          requestPermission().then(granted => {
            this.settings.enableDesktopNotifications = granted || null
          })
          return
        }
        this.settings[key] = value[key]
      })
    },
    loadSettings() {
      this.settings = getSettingsStore()
      if (!notificationsEnabled()) {
        // Sync in case desktop notifications were changed externally
        this.settings.enableDesktopNotifications = notificationsEnabled()
      }
    },
    updateNotifications() {
      const alertsByTicker = this.settings.alerts.reduce((obj, alertSetting) => {
        const alerts = getPriceAlerts(this.summaryData, alertSetting)
        alerts.forEach(alert => {
          obj[alert.ticker] = alert
        })
        return obj
      }, {})

      const notifications = Object.values(alertsByTicker).map(alert => {
        const lastReadTimestamp = this.settings.lastReadTimestamp
        const isRead = lastReadTimestamp != null && lastReadTimestamp >= alert.updateTimestamp
        return { ...alert, isRead }
      })

      this.notifications = notifications.concat(this.notifications)
      return notifications
    },
    sendNotifications(notifications) {
      if (this.settings.enableDesktopNotifications && !document.hasFocus()) {
        sendNotifications(notifications, {
          onRead: this.handleNotificationsRead
        })
      }
    },
    handleNotificationsRead() {
      this.notifications = this.notifications.map(item => ({ ...item, isRead: true }))
      const timestamps = this.notifications.map(item => item.updateTimestamp)
      this.settings.lastReadTimestamp = Math.max(...timestamps)
    },
    updateUnreadIndicator() {
      if (!this.hasUnreadNotifications) {
        updateDocumentTitle({ newUnread: false })
      } else if (!document.hasFocus()) {
        updateDocumentTitle({ newUnread: true })
      }
    }
  }
}
</script>