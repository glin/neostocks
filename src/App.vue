<template>
  <div>
    <Header />
    <b-container class="content">
      <router-view name="nav" />
      <keep-alive>
        <router-view v-bind="stockData" name="main" />
      </keep-alive>
    </b-container>
    <Footer :update-time="updateTime" />
  </div>
</template>

<style>
@import url('//fonts.googleapis.com/css?family=Open+Sans:400');
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
}
</style>

<script>
import Header from './components/Header'
import Footer from './components/Footer'

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
      marketIndex: null
    }
  },

  computed: {
    stockData() {
      return {
        summaryData: this.summaryData,
        hotStocks: this.hotStocks,
        marketIndex: this.marketIndex
      }
    }
  },

  created() {
    Shiny.addCustomMessageHandler('stock-data', msg => {
      this.summaryData = msg.summary_data
      this.hotStocks = msg.hot_stocks
      this.updateTime = msg.update_time
    })

    Shiny.addCustomMessageHandler('market-index', msg => {
      this.marketIndex = msg.data
    })
  }
}
</script>