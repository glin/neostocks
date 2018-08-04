<template>
  <div>
    <Heading class="heading">{{ title }}</Heading>
    <PeriodNav :period="period" />

    <b-table v-if="currentItems" :items="currentItems" :fields="currentFields" :filter="filterItem" :sort-by="sortBy" :sort-desc="sortDesc" class="summary" hover striped responsive>
      <template slot="ticker" slot-scope="data">
        <div class="ticker">
          <router-link :to="'/tickers/' + data.value + query" class="ticker-link">
            <img :src="getCompanyLogo(data.value)" :alt="data.value" class="company-logo">
            <span class="ticker-text">{{ data.value }}</span>
          </router-link>
          <a v-if="filter === 'bargain'" :href="getBuyUrl(data.value)" target="_blank" rel="noopener noreferrer">
            <span class="buy-link">(buy)</span>
          </a>
        </div>
      </template>
      <template slot="change" slot-scope="data">
        <span :class="numChangeClass(data.value)">{{ formatNum(data.value) }}</span>
      </template>
      <template slot="high" slot-scope="data">
        <span v-b-tooltip.hover :title="formatDate(data)" class="num-high">{{ data.value }}</span>
      </template>
    </b-table>
  </div>
</template>

<style>
.summary table {
  margin-bottom: 0;
}

.summary th,
.summary td {
  padding: 0.35rem 0.5rem;
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

.num-high {
  border-bottom: 1px dotted #888;
}
</style>

<style scoped>
@media (min-width: 576px) {
  .heading {
    display: none;
  }
}

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
</style>

<script>
import Heading from './Heading'
import PeriodNav from './PeriodNav'

export default {
  components: {
    Heading,
    PeriodNav
  },

  props: {
    period: {
      type: String,
      default: '1d'
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
    companies: {
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
          sortDirection: 'desc'
        },
        {
          key: 'avg',
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
          sortDirection: 'desc'
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
    currentItems() {
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
    currentFields() {
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
    query() {
      return this.$route.query.period
        ? `?period=${this.$route.query.period}`
        : ''
    }
  },

  methods: {
    numChangeClass(val) {
      if (val > 0) return 'num-positive num-change'
      if (val < 0) return 'num-negative num-change'
      return 'num-zero num-change'
    },
    formatNum(val) {
      if (val > 0) return '+' + val
      return val
    },
    formatDate(val) {
      const date = new Date(val.item.time_high)
      return date.toLocaleString() + ' NST'
    },
    filterItem(item) {
      switch (this.filter) {
        case 'bargain':
          return this.bargainFilter(item)
        case 'hot':
          return this.hotFilter(item)
        default:
          return true
      }
    },
    bargainFilter(item) {
      const price = item.curr
      return price >= 15 && price < 20
    },
    hotFilter(item) {
      return this.hotStocks && this.hotStocks.includes(item.ticker)
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