<template>
  <div>
    <Header />
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
      companies: getCompanyData()
    }
  },

  computed: {
    stockData() {
      return {
        summaryData: this.summaryData,
        hotStocks: this.hotStocks
      }
    }
  },

  created() {
    Shiny.addCustomMessageHandler('stock-data', msg => {
      this.summaryData = msg.summary_data
      this.hotStocks = msg.hot_stocks
      this.updateTime = msg.update_time
    })
  }
}
</script>