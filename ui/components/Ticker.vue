<template>
  <div>
    <PageNotFound v-if="!tickerFound" />
    <Card v-if="tickerFound">
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
        <Dygraph v-show="!isLoading" :data="priceData" :annotations="annotations" class="price-graph"/>
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
              :title="formatDateTime(data.item.last_peak_nst)"
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
import { timeSince, toDateString, toDateTimeString } from '../date'
import { updateDocumentTitle } from '../document';

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
    priceData() {
      if (!this.prices) return null
      return {
        time: this.prices.time,
        [this.ticker]: this.prices.curr
      }
    },
    company() {
      return this.companies[this.ticker]
    },
    tickerFound() {
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
      return this.summary[this.period]
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
      return toDateString(this.currentSummary.time_high_nst)
    },
    currentHighTimeFormatted() {
      if (this.period === 'all') {
        return toDateString(this.currentSummary.time_high_nst)
      }
      return toDateTimeString(this.currentSummary.time_high_nst) + ' NST'
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
    ticker() {
      this.selectTicker()
    },
    period() {
      this.selectTicker()
    },
    tickerFound: {
      handler() {
        if (!this.tickerFound) {
          updateDocumentTitle({ newPageTitle: 'page not found' })
        }
      },
      immediate: true
    },
    summaryData() {
      // Ensure that stock charts are updated on data updates. On the initial
      // page load, no ticker will be selected since price data is preloaded.
      this.selectTicker()
    }
  },

  created() {
    this.$store.dispatch(types.TICKER_SUBSCRIBE)
    if (!this.prices) {
      // Not the initial page load, must fetch price data from the server
      this.selectTicker()
    }
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
    formatDateTime(val) {
      return toDateTimeString(val) + ' NST'
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
        const date = toDateString(this.summary.all.last_peak_nst)
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

<style lang="scss">
@import '../assets/scss/variables';

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
  color: $dark-orange !important;
  border: none;
  background: transparent;
}

.numeric {
  text-align: right;
}
</style>

<style lang="scss" scoped>
@import '../assets/scss/variables';

.heading {
  display: flex;
  flex-direction: column;
  margin: 0 5px;
  font-size: 1.25rem;
}

.heading-divider {
  margin: 0.3125rem 0 0.7rem;
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
  color: $gray-600;
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
  color: $external-link-color;
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
  color: $positive-color;
}

.num-negative {
  color: $negative-color;
}

.num-zero {
  color: $zero-color;
}

.hoverable {
  border-bottom: 1px dotted #888;
}

.time-period {
  font-size: 0.85rem;
}

.current-high {
  font-weight: 600;
  color: $dark-orange;
}
</style>