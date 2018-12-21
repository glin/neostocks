<template>
  <Card>
    <PeriodNav :period="period" />

    <b-table v-if="currentItems" :items="currentItems" :fields="currentFields" :filter="filterItem" :sort-by="sortBy" :sort-desc="sortDesc" :empty-filtered-text="emptyFilterText" class="summary" hover striped responsive show-empty>
      <template slot="ticker" slot-scope="data">
        <div class="ticker">
          <router-link :to="{ path: '/tickers/' + data.value, query }" class="ticker-link">
            <img :src="getCompanyLogo(data.value)" :alt="data.value" class="company-logo">
            <span class="ticker-text">{{ data.value }}</span>
          </router-link>
          <a v-if="filter === 'bargain'" :href="getBuyUrl(data.value)">
            <span class="buy-link">(buy)</span>
          </a>
          <span v-if="filter === 'hot' && isHotStockNew(data.value)" class="new-hot-tag">new!</span>
        </div>
      </template>
      <!-- <template slot="volume" slot-scope="data">
        <span :title="data.value.toLocaleString()">{{ formatNum(data.value) }}</span>
      </template> -->
      <template slot="change" slot-scope="data">
        <span :class="numChangeClass(data.value)">{{ formatChange(data.value) }}</span>
      </template>
      <template slot="high" slot-scope="data">
        <span v-b-tooltip.hover :title="formatDate(data.item.time_high, period !== 'all')" :class="{ 'current-high': filter === 'hot' && isCurrentHigh(data.item.curr, data.value) }" class="hoverable">{{ data.value }}</span>
      </template>
      <template slot="num_peaks" slot-scope="data">
        <span v-b-tooltip.hover :title="`~${data.item.avg_days_peak} days between peaks`" class="hoverable">{{ data.value }}</span>
      </template>
      <template slot="avg_days_peak" slot-scope="data">
        <span class="time-period">{{ `${data.value} days` }}</span>
      </template>
      <template slot="last_peak" slot-scope="data">
        <span :title="formatDate(data.item.last_peak_nst)" class="time-period">{{ formatTimeSince(data.value) }}</span>
      </template>
    </b-table>
  </Card>
</template>

<style>
.summary table {
  margin-bottom: 0;
}

.summary th,
.summary td {
  padding: 0.35rem 0.5rem;
  white-space: nowrap;
  border-color: #e9ecef;
}

.summary th:focus {
  outline: 0;
}

.summary th {
  border-top: 0;
}

.table-striped tbody tr:nth-of-type(odd) {
  background-color: #f9f9f9;
}

.table-hover tbody tr:hover {
  background-color: #f6f6f6;
}

.numeric {
  text-align: right;
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
  color: #6c757d;
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

<style scoped>
.ticker {
  white-space: nowrap;
}

.ticker-link:hover {
  text-decoration: none;
}

.company-logo {
  margin: -5px 5px -2px 0;
  height: 25px;
}

.ticker-text {
  display: inline-block;
  width: 50px;
}

.buy-link {
  font-size: small;
  color: #1e7e34;
}

.new-hot-tag {
  font-size: small;
  color: #e36209;
}
</style>

<script>
import bTable from 'bootstrap-vue/es/components/table/table'
import bTooltip from 'bootstrap-vue/es/directives/tooltip/tooltip'

import Heading from './Heading'
import Card from './Card'
import PeriodNav from './PeriodNav'
import { timeSince } from '../date'

export default {
  components: {
    bTable,
    Heading,
    Card,
    PeriodNav
  },

  directives: {
    bTooltip
  },

  props: {
    period: {
      type: String,
      default: '1d',
      validator: function(value) {
        return ['1d', '5d', '1m', 'all'].includes(value)
      }
    },
    summaryData: {
      type: Object,
      default: null
    },
    hotStocks: {
      type: Array,
      default: null
    },
    filter: {
      type: String,
      default: ''
    },
    search: {
      type: String,
      default: ''
    },
    companies: {
      type: Object,
      required: true
    },
    query: {
      type: Object,
      required: true
    }
  },

  data() {
    return {
      fields: [
        { key: 'ticker', sortable: true },
        {
          key: 'volume',
          class: 'numeric',
          sortable: true,
          sortDirection: 'desc',
          formatter: value => value.toLocaleString()
        },
        {
          key: 'open',
          class: 'numeric',
          sortable: true,
          sortDirection: 'desc'
        },
        {
          key: 'curr',
          label: 'Current',
          class: 'numeric',
          sortable: true,
          sortDirection: 'desc'
        },
        {
          key: 'change',
          class: 'numeric',
          sortable: true,
          sortDirection: 'desc'
        },
        {
          key: 'high',
          class: 'numeric',
          sortable: true,
          sortDirection: 'desc'
        },
        {
          key: 'low',
          class: 'numeric',
          sortable: true,
          sortDirection: 'desc',
          periods: ['1d', '5d', '1m']
        },
        {
          key: 'range',
          class: 'numeric',
          sortable: true,
          sortDirection: 'desc',
          periods: ['1d', '5d', '1m']
        },
        {
          key: 'avg_peak',
          label: 'Avg Peak',
          class: 'numeric',
          sortable: true,
          sortDirection: 'desc'
        },
        {
          key: 'last_peak',
          label: 'Last Peak',
          class: 'numeric',
          sortable: true,
          sortDirection: 'desc'
        },
        {
          key: 'avg_days_peak',
          label: 'Peak Frequency',
          class: 'numeric',
          sortable: true,
          sortDirection: 'asc'
        },
        {
          key: 'avg',
          class: 'numeric',
          sortable: true,
          sortDirection: 'desc',
          periods: ['none']
        },
        {
          key: 'pct_95',
          label: 'Top 5%',
          class: 'numeric',
          sortable: true,
          sortDirection: 'desc',
          periods: ['all']
        },
        {
          key: 'median',
          class: 'numeric',
          sortable: true,
          sortDirection: 'desc',
          periods: ['all']
        },
        {
          key: 'sd',
          label: 'Volatility',
          class: 'numeric',
          sortable: true,
          sortDirection: 'desc',
          periods: ['none']
        },
        {
          key: 'avg_volume',
          label: 'Avg Volume',
          class: 'numeric',
          sortable: true,
          sortDirection: 'desc',
          formatter: value => value.toLocaleString()
        }
      ]
    }
  },

  computed: {
    title() {
      switch (this.filter) {
        case 'bargain':
          return 'Bargain Stocks'
        case 'hot':
          return 'Hot Stocks'
        default:
          return 'Summary'
      }
    },
    period_1d() {
      if (!this.summaryData) return null
      return this.summaryData.period_1d
    },
    period_5d() {
      if (!this.summaryData) return null
      return this.summaryData.period_5d
    },
    period_1m() {
      if (!this.summaryData) return null
      return this.summaryData.period_1m
    },
    period_all() {
      if (!this.summaryData) return null
      return this.summaryData.period_all
    },
    currentSummary() {
      switch (this.period) {
        case '1d':
          return this.period_1d
        case '5d':
          return this.period_5d
        case '1m':
          return this.period_1m
        case 'all':
          return this.period_all
      }
    },
    currentItems() {
      return this.currentSummary.filter(item => item.ticker !== 'NEODAQ')
    },
    currentFields() {
      if (this.currentItems.length === 0) return
      const keys = Object.keys(this.currentItems[0])
      const fields = this.fields.filter(field => {
        if (field.periods && !field.periods.includes(this.period)) {
          return false
        }
        return keys.includes(field.key)
      })
      return fields
    },
    sortBy() {
      if (this.filter === 'bargain') return 'curr'
      if (this.filter === 'hot') return 'curr'
      return null
    },
    sortDesc() {
      if (this.filter === 'bargain') return false
      if (this.filter === 'hot') return true
      return null
    },
    emptyFilterText() {
      return (
        'There are no ' +
        (this.filter ? `${this.filter} stocks ` : 'tickers ') +
        (this.search ? `matching <i> ${this.search}</i>` : 'at the moment')
      )
    }
  },

  methods: {
    numChangeClass(val) {
      if (val > 0) return 'num-positive num-change'
      if (val < 0) return 'num-negative num-change'
      return 'num-zero num-change'
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
    // Adapted from https://stackoverflow.com/questions/9461621
    formatNum(num) {
      const si = [
        { value: 1, suffix: '' },
        { value: 1e3, suffix: 'k' },
        { value: 1e6, suffix: 'M' },
        { value: 1e9, suffix: 'B' }
      ]
      const regex = /\.0+$|(\.[0-9]*[1-9])0+$/
      let i
      for (i = si.length - 1; i > 0; i--) {
        if (num >= si[i].value) {
          break
        }
      }
      const abbrev = num / si[i].value
      const numDigits = abbrev.toString().replace('.', '').length
      const digits = numDigits < 3 ? 1 : 0
      return abbrev.toFixed(digits).replace(regex, '$1') + si[i].suffix
    },
    filterItem(item) {
      const searchMatch = this.searchFilter(item)
      switch (this.filter) {
        case 'bargain':
          return searchMatch && this.bargainFilter(item)
        case 'hot':
          return searchMatch && this.hotFilter(item)
        default:
          return searchMatch
      }
    },
    searchFilter(item) {
      if (!this.search) return true
      const searchItems = this.search
        .split(/[\s,]/)
        .filter(s => s != '')
        .map(s => s.toUpperCase())
      return searchItems.some(search => item.ticker.match(search))
    },
    bargainFilter(item) {
      const price = item.curr
      return price >= 15 && price < 20
    },
    hotFilter(item) {
      return this.isHotStock(item.ticker)
    },
    isHotStock(ticker) {
      return (
        this.hotStocks && this.hotStocks.some(stock => stock.ticker === ticker)
      )
    },
    isHotStockNew(ticker) {
      return (
        this.hotStocks &&
        this.hotStocks.some(stock => stock.ticker === ticker && stock.new)
      )
    },
    isCurrentHigh(curr, high) {
      return curr === high && curr >= 30
    },
    getCompanyLogo(ticker) {
      return this.companies[ticker].logo
    },
    getBuyUrl(ticker) {
      return this.companies[ticker].buyUrl
    }
  }
}
</script>