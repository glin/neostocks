<template>
  <div>
    <PageNotFound v-if="!showTicker" />
    <Card v-if="showTicker">
      <div class="heading">
        <div class="d-flex align-items-center">
          <img :src="company.logo" class="company-logo" alt>
          <div class="d-flex align-items-baseline">
            <span class="company-ticker">{{ ticker }}</span>
            <span class="company-name">{{ company.company }}</span>
          </div>
        </div>

        <div class="d-flex justify-content-between">
          <div class="current-price">
            <span>{{ currentPrice }}</span>
            <span
              v-if="!isNaN(currentChange)"
              :class="numChangeClass(currentChange)"
              class="current-change"
            >{{ formatChange(currentChange) }}</span>
          </div>

          <div v-if="company.buyUrl && company.profileUrl" class="company-links">
            <a :href="company.buyUrl">buy</a>
            <span class="v-divider">|</span>
            <a :href="company.profileUrl">profile</a>
          </div>
        </div>
      </div>

      <hr class="heading-divider">

      <PeriodNav :period="period"/>
      <div class="price-graph-container">
        <Dygraph v-show="!isLoading" :data="prices" :annotations="annotations" class="price-graph"/>
      </div>

      <hr class="content-divider">

      <div v-for="tbl in summaryTables" :class="tbl.class" :key="tbl.class">
        <b-table
          v-for="keys in tbl.keys"
          :key="keys[0]"
          :items="currentItems"
          :fields="keys.map(key => fields.find(f => f.key === key))"
          class="summary-table"
          small
          stacked
        >
          <template slot="change" slot-scope="data">
            <span
              :class="numChangeClass(data.value)"
              class="num-change"
            >{{ formatChange(data.value) }}</span>
          </template>
          <template slot="high" slot-scope="data">
            <span
              v-b-tooltip
              :title="currentHighTimeFormatted"
              :class="{ 'current-high': isCurrentHigh }"
              class="hoverable"
              @mouseover="handleHighHover(true)"
              @mouseleave="handleHighHover(false)"
            >{{ data.value }}</span>
          </template>
          <template slot="avg_peak" slot-scope="data">
            <span
              v-b-tooltip
              :title="`~${data.item.avg_days_peak} days between peaks`"
              class="hoverable"
              @mouseover="handlePeaksHover(true)"
              @mouseleave="handlePeaksHover(false)"
            >{{ data.value }}</span>
          </template>
          <template slot="avg_days_peak" slot-scope="data">
            <span class="time-period">{{ `${data.value} days` }}</span>
          </template>
          <template slot="last_peak" slot-scope="data">
            <span
              v-b-tooltip
              :title="formatDate(data.item.last_peak_nst)"
              class="hoverable time-period"
              @mouseover="handleLastPeakHover(true)"
              @mouseleave="handleLastPeakHover(false)"
            >{{ formatTimeSince(data.value) }}</span>
          </template>
        </b-table>
      </div>
    </Card>
  </div>
</template>

<script>
import { mapState } from 'vuex'
import bTable from 'bootstrap-vue/es/components/table/table'
import bTooltip from 'bootstrap-vue/es/directives/tooltip/tooltip'

import Card from './Card'
import Dygraph from './Dygraph'
import PeriodNav from './PeriodNav'
import PageNotFound from './PageNotFound'
import * as types from '../store/types'
import { timeSince } from '../date'

export default {
  components: {
    bTable,
    Card,
    Dygraph,
    PeriodNav,
    PageNotFound
  },

  directives: {
    bTooltip
  },

  props: {
    ticker: {
      type: String,
      required: true
    },
    period: {
      type: String,
      default: '1d',
      validator: function(value) {
        return ['1d', '5d', '1m', 'all'].includes(value)
      }
    },
    companies: {
      type: Object,
      required: true
    }
  },

  data() {
    return {
      fields: [
        {
          key: 'volume',
          class: 'numeric',
          formatter: value => value.toLocaleString()
        },
        {
          key: 'open',
          class: 'numeric'
        },
        {
          key: 'curr',
          label: 'Current',
          class: 'numeric'
        },
        {
          key: 'change',
          class: 'numeric'
        },
        {
          key: 'high',
          class: 'numeric'
        },
        {
          key: 'low',
          class: 'numeric'
        },
        {
          key: 'range',
          class: 'numeric'
        },
        {
          key: 'avg',
          class: 'numeric'
        },
        {
          key: 'median',
          class: 'numeric'
        },
        {
          key: 'sd',
          label: 'Volatility',
          class: 'numeric'
        },
        {
          key: 'avg_volume',
          label: 'Avg Volume',
          class: 'numeric',
          formatter: value => value.toLocaleString()
        },
        {
          key: 'avg_peak',
          label: 'Avg Peak',
          class: 'numeric'
        },
        {
          key: 'num_peaks',
          label: '# Peaks',
          class: 'numeric'
        },
        {
          key: 'avg_days_peak',
          label: 'Peak Freq',
          class: 'numeric'
        },
        {
          key: 'last_peak',
          label: 'Last Peak',
          class: 'numeric'
        },
        {
          key: 'pct_95',
          label: 'Top 5%',
          class: 'numeric'
        }
      ],
      highAnnotation: null,
      peakAnnotations: null,
      lastPeakAnnotation: null
    }
  },

  computed: {
    company() {
      return this.companies[this.ticker]
    },
    showTicker() {
      return this.company != null
    },
    summary() {
      const periods = Object.keys(this.summaryData)
      return periods.reduce((data, period) => {
        data[period] = this.summaryData[period].find(row => row.ticker === this.ticker)
        return data
      }, {})
    },
    currentSummary() {
      switch (this.period) {
        case '1d':
          return this.summary.period_1d
        case '5d':
          return this.summary.period_5d
        case '1m':
          return this.summary.period_1m
        case 'all':
          return this.summary.period_all
      }
    },
    currentPrice() {
      return this.currentSummary.curr
    },
    currentChange() {
      return this.currentSummary.change
    },
    currentItems() {
      return [this.currentSummary]
    },
    isCurrentHigh() {
      return this.currentPrice === this.currentSummary.high && this.currentPrice >= 30
    },
    currentHighTime() {
      if (this.period === 'all') {
        const date = new Date(this.currentSummary.time_high)
        return date.toLocaleDateString()
      }
      return this.currentSummary.time_high
    },
    currentHighTimeFormatted() {
      const date = new Date(this.currentSummary.time_high)
      if (this.period === 'all') {
        return date.toLocaleDateString()
      }
      return date.toLocaleString() + ' NST'
    },
    summaryTables() {
      return [
        { class: 'summary-tables', keys: this.currentKeys },
        { class: 'summary-tables-compact', keys: this.currentKeysCompact }
      ]
    },
    currentKeys() {
      if (this.period === 'all') {
        return [['avg_peak', 'last_peak'], ['high', 'low'], ['pct_95', 'median']]
      }
      return [['open', 'volume'], ['high', 'low'], ['range', 'median']]
    },
    currentKeysCompact() {
      if (this.period === 'all') {
        return [['high', 'low', 'median'], ['avg_peak', 'last_peak', 'pct_95']]
      }
      return [['high', 'low', 'median'], ['open', 'volume', 'range']]
    },
    annotations() {
      let annotations = []
      if (this.highAnnotation) {
        annotations.push(this.highAnnotation)
      }
      if (this.peakAnnotations) {
        annotations.push(...this.peakAnnotations)
      }
      if (this.lastPeakAnnotation) {
        annotations.push(this.lastPeakAnnotation)
      }
      return annotations
    },
    ...mapState({
      summaryData: state => state.stocks.summaryData,
      isLoading: state => state.ticker.isLoading,
      prices: state => state.ticker.prices,
      peaks: state => state.ticker.peaks
    })
  },

  watch: {
    ticker: {
      handler() {
        this.selectTicker()
      },
      immediate: true
    },
    period: {
      handler() {
        this.selectTicker()
      },
      immediate: true
    }
  },

  created() {
    this.$store.dispatch(types.TICKER_SUBSCRIBE)
    this.selectTicker()
  },

  methods: {
    selectTicker() {
      this.$store.dispatch(types.TICKER_SELECT_TICKER, {
        ticker: this.ticker,
        period: this.period
      })
    },
    numChangeClass(val) {
      if (val > 0) return 'num-positive'
      if (val < 0) return 'num-negative'
      return 'num-zero'
    },
    formatChange(val) {
      if (val >= 0) return '+' + val
      return val
    },
    formatDate(val, time = true) {
      const date = new Date(val)
      return time
        ? date.toLocaleString() + ' NST'
        : date.toLocaleDateString({}, { timeZone: 'UTC' })
    },
    formatTimeSince(then) {
      return timeSince(new Date(then))
    },
    handleHighHover(hovered) {
      if (hovered) {
        this.highAnnotation = {
          series: this.ticker,
          x: this.currentHighTime,
          shortText: '•',
          text: '',
          height: 20,
          cssClass: 'peak-annotation',
          tickColor: '#e36209',
          tickHeight: -5,
          tickWidth: 0
        }
      } else {
        this.highAnnotation = null
      }
    },
    handlePeaksHover(hovered) {
      if (hovered) {
        this.peakAnnotations = this.peaks.map(date => {
          return {
            series: this.ticker,
            x: date,
            shortText: '•',
            text: '',
            height: 20,
            cssClass: 'peak-annotation',
            tickColor: '#e36209',
            tickHeight: -5,
            tickWidth: 0
          }
        })
      } else {
        this.peakAnnotations = null
      }
    },
    handleLastPeakHover(hovered) {
      if (hovered) {
        const date = new Date(this.summary.period_all.last_peak_nst).toLocaleDateString()
        this.lastPeakAnnotation = {
          series: this.ticker,
          x: date,
          shortText: '•',
          text: '',
          height: 20,
          cssClass: 'peak-annotation',
          tickColor: '#e36209',
          tickHeight: -5,
          tickWidth: 0
        }
      } else {
        this.lastPeakAnnotation = null
      }
    }
  }
}
</script>

<style>
.summary-table.table td:first-child {
  border: none;
}

.summary-table th,
.summary-table td {
  padding: 0.25rem 0.3rem;
  border-color: hsl(210, 13%, 95%);
  border: none;
}

.summary-table.table {
  margin-bottom: 0;
}

.peak-annotation {
  font-size: 20px !important;
  color: #e36209 !important;
  border: none;
  background: transparent;
}

.numeric {
  text-align: right;
}
</style>

<style lang="scss" scoped>
@import "../assets/scss/variables";

.heading {
  display: flex;
  flex-direction: column;
  margin: 0 5px;
  font-size: 1.25rem;
}

.heading-divider {
  margin: 0.3125rem 0 0.8125rem;
  border-top-color: hsl(210, 13%, 91%);
}

.company-ticker {
  font-size: 1.2rem;
}

.company-logo {
  margin-right: 0.5rem;
  height: 25px;
}

.company-name {
  margin-left: 0.75rem;
  font-size: 0.9rem;
  color: #6c757d;
}

.current-price {
  font-size: 2.25rem;
  margin-bottom: -8px;
}

.current-change {
  margin-left: 0.25rem;
  font-size: 1.2rem;
  font-weight: 600;
}

.company-links {
  margin-top: auto;
  white-space: nowrap;
  font-size: 0.8125rem;
}

.company-links a {
  color: #1e7e34;
}

.v-divider {
  color: #aaa;
}

.content-divider {
  margin: 0.9rem 0 0.3125rem;
  border-top: 1px solid hsl(210, 13%, 95%);
}

.price-graph-container {
  padding-top: 0.5rem;
  height: 300px;
}

@include media-breakpoint-down(xs) {
  .price-graph-container {
    height: 200px;
  }

  .price-graph {
    max-height: 200px;
  }
}

.summary-tables {
  display: flex;
}

.summary-tables-compact {
  display: none;
}

@include media-breakpoint-down(xs) {
  .summary-tables {
    display: none;
  }

  .summary-tables-compact {
    display: flex;
  }
}

.summary-table {
  flex-basis: 0;
  flex-grow: 1;
  white-space: nowrap;
}

.num-change {
  font-weight: 600;
}

.num-positive {
  color: green;
}

.num-negative {
  color: red;
}

.num-zero {
  color: #495057;
}

.hoverable {
  border-bottom: 1px dotted #888;
}

.time-period {
  font-size: 0.85rem;
}

.current-high {
  font-weight: 600;
  color: #e36209;
}
</style>