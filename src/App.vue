<template>
  <div>
    <Header :search="search" :on-search="handleSearch" :search-results="searchResults" :clear-search="clearSearch" :query="query" />
    <b-container class="content">
      <keep-alive>
        <router-view v-bind="stockData" :companies="companies" />
      </keep-alive>
    </b-container>
    <Footer :update-time="updateTime" />
  </div>
</template>

<style>
@import url('https://fonts.googleapis.com/css?family=Open+Sans:400');

body {
  background-color: #f7f7f7 !important;
  font-family: 'Open Sans';
  overflow-y: scroll;
}
</style>

<style scoped>
.content {
  margin-top: 15px;
  padding: 10px;
  background-color: #fff;
  border: 1px solid lightgrey;
  border-radius: 2px;
}

@media (max-width: 575.98px) {
  .content {
    margin-top: 7.5px;
  }
}
</style>

<script>
import Header from './components/Header'
import Footer from './components/Footer'
import { getCompanyData } from './companies'

export default {
  components: {
    Header,
    Footer
  },

  data() {
    return {
      summaryData: window.__data__.summary_data,
      hotStocks: window.__data__.hot_stocks,
      updateTime: window.__data__.update_time,
      companies: getCompanyData(),
      search: ''
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
          href: '/tickers/' + ticker + this.query
        }
      })
    },
    query() {
      return this.$route.query.period
        ? `?period=${this.$route.query.period}`
        : ''
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
    handleSearch(val) {
      this.search = val
    },
    clearSearch() {
      this.search = ''
    }
  }
}
</script>