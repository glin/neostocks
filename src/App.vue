<template>
  <div class="main">
    <div class="main-container">
      <Header :search="search" :search-results="searchResults" :on-search-change="handleSearchChange" :on-search-submit="handleSearchSubmit" :notifications="notifications" :on-notifications-read="handleNotificationsRead" :query="query" />
      <b-container class="main-content">
        <keep-alive>
          <router-view v-bind="stockData" :companies="companies" :settings="settings" :on-settings-change="handleSettingsChange" :query="query" />
        </keep-alive>
      </b-container>
      <UpdateTime v-if="showUpdateTime" :update-time="updateTime" />
    </div>
    <Footer />
  </div>
</template>

<style>
@import url('https://fonts.googleapis.com/css?family=Open+Sans:400,600');

html,
body {
  height: 100%;
}

body {
  overflow-y: scroll;
  background-color: #f7f7f7 !important;
  font-family: 'Open Sans';
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
  margin-top: 56px;
  margin-bottom: 30px;
}

.main-content {
  margin-top: 15px;
  padding: 10px;
  background-color: #fff;
  box-shadow: 0 1px 4px #ddd;
}

@media (max-width: 575.98px) {
  .main-container {
    min-height: 100vh;
  }

  .main-content {
    margin-top: 7.5px;
  }
}
</style>

<script>
import Header from './components/Header'
import Footer from './components/Footer'
import UpdateTime from './components/UpdateTime'
import companies from './companies'
import { getSettingsStore } from './settings'
import { notificationsEnabled, requestPermission } from './notifications'
import { getPriceAlerts, sendNotifications } from './alerts'
import { DAY } from './date'

export default {
  components: {
    Header,
    Footer,
    UpdateTime
  },

  data() {
    return {
      summaryData: window.__data__.summary_data,
      hotStocks: window.__data__.hot_stocks,
      updateTime: window.__data__.update_time,
      search: '',
      settings: {},
      notifications: [],
      now: new Date(),
      isPageVisible: true,
      companies
    }
  },

  computed: {
    stockData() {
      return {
        summaryData: this.summaryData,
        hotStocks: this.hotStocks
      }
    },
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
    query() {
      const query = {}
      if (this.$route.query.period) {
        query.period = this.$route.query.period
      }
      return query
    }
  },

  watch: {
    summaryData() {
      this.updateNotifications()
    },
    now() {
      this.notifications = this.notifications.filter(item => {
        return this.now - new Date(item.updateTime) <= DAY * 5
      })
    }
  },

  created() {
    Shiny.addCustomMessageHandler('stock-data', this.handleStockDataChange)

    this.loadSettings()
    this.updateNotifications()

    setInterval(() => (this.now = new Date()), 60 * 1000)

    document.addEventListener('visibilitychange', this.handleVisibilityChange)
  },

  methods: {
    handleStockDataChange(data) {
      this.summaryData = data.summary_data
      this.hotStocks = data.hot_stocks
      this.updateTime = data.update_time
    },
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

      if (this.settings.enableDesktopNotifications && !this.isPageVisible) {
        const unreadNotifications = notifications.filter(item => !item.isRead)
        sendNotifications(unreadNotifications, {
          onClick: this.handleNotificationsRead,
          onClose: this.handleNotificationsRead
        })
      }
    },
    handleNotificationsRead() {
      if (this.notifications.length > 0) {
        this.notifications = this.notifications.map(item => ({ ...item, isRead: true }))
        const timestamps = this.notifications.map(item => item.updateTimestamp)
        this.settings.lastReadTimestamp = Math.max(...timestamps)
      }
    },
    handleVisibilityChange() {
      this.isPageVisible = !document.hidden
    }
  }
}
</script>