<template>
  <div>
    <b-row>
      <b-col lg="6" class="trends-col">
        <Card class="trends-card">
          <div class="chart-heading">
            <div class="d-flex flex-column align-items-center">
              <span class="chart-title">Average Days to Sell Point</span>
              <span class="chart-subtitle">starting from 15 NP</span>
            </div>
          </div>
          <BarChart
            :data="daysFrom15"
            :tooltip-name-formatter="formatPrice"
            :tooltip-value-formatter="formatDays"
            :y-axis-label-formatter="formatDays"
          />
        </Card>
      </b-col>

      <b-col lg="6" class="trends-col">
        <Card class="trends-card">
          <div class="chart-heading">
            <span class="chart-title">Price Distribution</span>
          </div>
          <BarChart
            :data="priceDist"
            :y-axis-label-formatter="formatPercent"
            :tooltip-name-formatter="formatPrice"
            :tooltip-value-formatter="formatPercent"
          />
        </Card>
      </b-col>
    </b-row>

    <b-row>
      <b-col lg="6" class="trends-col">
        <Card class="trends-card">
          <div class="chart-heading">
            <span class="chart-title">Shares Bought by Day</span>
          </div>
          <div class="dygraph-container">
            <Dygraph :data="volumeByDayData" :options="{ labelsKMB: true, colors: ['#3398db'] }"/>
          </div>
        </Card>
      </b-col>

      <b-col lg="6" class="trends-col">
        <Card class="trends-card">
          <div class="chart-heading">
            <span class="chart-title">Shares Bought by Price</span>
          </div>
          <BarChart
            :data="volumeByPrice"
            :y-axis-label-formatter="formatPercent"
            :tooltip-name-formatter="formatPrice"
            :tooltip-value-formatter="formatPercent"
          />
        </Card>
      </b-col>
    </b-row>
  </div>
</template>

<script>
import { mapState } from 'vuex'
import bCol from 'bootstrap-vue/es/components/layout/col'
import bRow from 'bootstrap-vue/es/components/layout/row'

import Card from './Card'

import LoadingSpinner from './LoadingSpinner'

const BarChart = () => ({
  component: import('./BarChart'),
  loading: LoadingSpinner,
  delay: 200
})

const Dygraph = () => ({
  component: import('./Dygraph'),
  loading: LoadingSpinner,
  delay: 200
})

export default {
  components: {
    bRow,
    bCol,
    BarChart,
    Card,
    Dygraph
  },

  computed: {
    volumeByDayData() {
      return {
        time: this.volumeByDay.map(data => data.date),
        Volume: this.volumeByDay.map(data => data.volume)
      }
    },
    ...mapState({
      daysFrom15: state => state.stocks.daysFrom15,
      priceDist: state => state.stocks.priceDist,
      volumeByPrice: state => state.stocks.volumeByPrice,
      volumeByDay: state => state.stocks.volumeByDay
    })
  },

  methods: {
    formatDays(value) {
      return `${value.toLocaleString()} days`
    },
    formatPercent(value) {
      return `${value}%`
    },
    formatPrice(value) {
      return `${value} NP`
    }
  }
}
</script>

<style lang="scss" scoped>
@import '../assets/scss/variables';

.trends-card {
  height: 300px;
}

@include media-breakpoint-down(md) {
  .trends-col:not(:first-of-type) {
    margin-top: 1rem;
  }
}

.row {
  margin-top: 1rem;
}

.chart-heading {
  margin: 0 auto;
  margin-bottom: 0.5rem;
}

.chart-title {
  font-size: 1rem;
  font-weight: 600;
  color: #545b62;
}

.chart-subtitle {
  margin-top: 0.125rem;
  font-size: 0.8rem;
  color: #6c757d;
}

.dygraph-container {
  flex: 1 1 0;
}
</style>