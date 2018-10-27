<template>
  <div class="main">
    <div class="main-container">
      <Header :search="search" :search-results="searchResults" :on-search-change="handleSearchChange" :on-search-submit="handleSearchSubmit" :query="query" />
      <b-container class="main-content">
        <keep-alive>
          <router-view v-bind="stockData" :companies="companies" :query="query" />
        </keep-alive>
      </b-container>
      <UpdateTime v-if="showUpdateTime" :update-time="updateTime" />
    </div>
    <Footer />
  </div>
</template>

<style>
@import url('https://fonts.googleapis.com/css?family=Open+Sans:400');

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
  border: 1px solid lightgrey;
  border-radius: 2px;
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

  created() {
    Shiny.addCustomMessageHandler('stock-data', msg => {
      this.summaryData = msg.summary_data
      this.hotStocks = msg.hot_stocks
      this.updateTime = msg.update_time
    })
  },

  methods: {
    handleSearchChange(value) {
      this.search = value
    },
    handleSearchSubmit() {
      const query = { search: this.search, ...this.query }
      this.$router.push({ path: '/', query })
    }
  }
}
</script>