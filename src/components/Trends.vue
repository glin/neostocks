<template>
  <div>
    <b-row>
      <b-col
        lg="6"
        class="trends-col"
      >
        <Card class="trends-card">
          <div class="heading">
            <!-- <span class="title">Average Days Between Peaks</span> -->
            <span class="title">Average Days to Sell Point</span>
            <!-- <span class="title">Average Days to Peak</span> -->
            <!-- <span class="title">Average Days to Reach Price</span> -->
            <!-- <span class="subtitle">for a stock at 15 NP</span> -->
            <span class="subtitle">starting from 15 NP</span>
          </div>
          <BarChart
            :chart-data="daysFrom15"
            :tooltip-name-formatter="value => value + ' NP'"
            :tooltip-value-formatter="value => `<b>${value}</b> days`"
            x-axis-name="Price"
            y-axis-name="Days"
          />
        </Card>
      </b-col>
      <b-col
        lg="6"
        class="trends-col"
      >
        <Card class="trends-card">
          <div class="heading">
            <span class="title">Price Distribution</span>
          </div>
          <BarChart
            :chart-data="priceDist"
            :y-axis-label-formatter="value => value + '%'"
            :tooltip-name-formatter="value => value + ' NP'"
            :tooltip-value-formatter="value => `<b>${value}%</b>`"
            x-axis-name="Price"
          />
        </Card>
      </b-col>
    </b-row>

    <b-row>
      <b-col
        lg="6"
        class="trends-col"
      >
        <Card class="trends-card">
          <div class="heading">
            <!-- <span class="title">Shares Purchased By Day</span> -->
            <span class="title">Shares Bought by Day</span>
          </div>
          <div class="dygraph-container">
            <Dygraph
              :data="volumeByDayData"
              :options="{ labelsKMB: true, colors: ['#3398db'] }"
            />
          </div>
        </Card>
      </b-col>
      <b-col
        lg="6"
        class="trends-col"
      >
        <Card class="trends-card">
          <div class="heading">
            <span class="title">Shares Bought by Price</span>
            <!-- <span class="title">Shares Purchased by Price</span> -->
          </div>
          <BarChart
            :chart-data="volumeByPrice"
            :y-axis-label-formatter="value => value + '%'"
            :tooltip-name-formatter="value => value + ' NP'"
            :tooltip-value-formatter="value => `<b>${value}%</b>`"
            x-axis-name="Price"
          />
        </Card>
      </b-col>
    </b-row>
  </div>
</template>

<style scoped>
.trends-card {
  height: 300px;
}

@media (max-width: 991.98px) {
  .trends-col:not(:first-of-type) {
    margin-top: 16px;
  }
}

.row {
  margin-top: 15px;
}

.heading {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 8px;
}

.title {
  font-size: 1rem;
  font-weight: 600;
  color: #545b62;
}

.subtitle {
  margin-top: 2px;
  font-size: 0.8rem;
  color: #6c757d;
}

.dygraph-container {
  flex: 1 1 0;
}
</style>

<script>
import bCol from 'bootstrap-vue/es/components/layout/col'
import bRow from 'bootstrap-vue/es/components/layout/row'

import BarChart from './BarChart'
import Card from './Card'
import Dygraph from './Dygraph'

export default {
  components: {
    bRow,
    bCol,
    BarChart,
    Card,
    Dygraph
  },

  props: {
    daysFrom15: {
      type: Array,
      required: true
    },
    priceDist: {
      type: Array,
      required: true
    },
    volumeByPrice: {
      type: Array,
      required: true
    },
    volumeByDay: {
      type: Array,
      required: true
    }
  },

  computed: {
    volumeByDayData() {
      return {
        time: this.volumeByDay.map(data => data.date),
        Volume: this.volumeByDay.map(data => data.volume)
      }
    }
  }
}
</script>