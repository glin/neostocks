<template>
  <div>
    <PageNotFound v-if="!showTicker" />

    <div v-if="showTicker">
      <Heading>
        <div class="company-title">
          <img :src="company.logo" :alt="ticker" class="company-logo">
          <span>{{ ticker }}</span>
          <span class="company-name"> {{ company.company }} </span>
        </div>

        <div class="company-subtitle">
          <div class="current-price">
            <span>{{ currentPrice }}</span>
            <span :class="numChangeClass(currentChange)" class="current-change">{{ formatNum(currentChange) }}</span>
          </div>

          <div v-if="company.buyUrl && company.profileUrl" class="company-links">
            <a :href="company.buyUrl" target="_blank" rel="noopener noreferrer">buy</a>
            <span class="v-divider"> | </span>
            <a :href="company.profileUrl" target="_blank" rel="noopener noreferrer">profile</a>
          </div>
        </div>
      </Heading>

      <PeriodNav :period="period" />
      <Dygraph :data="data" class="price-graph" />

      <hr class="divider">

      <div v-for="tbl in summaryTables" :class="tbl.class" :key="tbl.class">
        <b-table v-for="keys in tbl.keys" :key="keys[0]" :items="currentItems" :fields="keys.map(key => fields.find(f => f.key === key))" class="summary-table" small stacked>
          <template slot="change" slot-scope="data">
            <span :class="numChangeClass(data.value)" class="num-change">{{ formatNum(data.value) }}</span>
          </template>
          <template slot="high" slot-scope="data">
            <span v-b-tooltip.hover :title="formatDate(data)" :class="isCurrentHigh ? 'current-high' : ''" class="num-high">{{ data.value }}</span>
          </template>
        </b-table>
      </div>
    </div>
  </div>
</template>

<style>
.summary-table.table td:first-child {
  border: none;
}

.summary-table.table {
  margin-bottom: 0;
}
</style>

<style scoped>
.company-title {
  font-size: 1.2rem;
}

.company-logo {
  margin-right: 0.15em;
  height: 25px;
}

.company-name {
  margin-left: 0.5em;
  font-size: 0.9rem;
  color: #6c757d;
}

.company-subtitle {
  display: flex;
  justify-content: space-between;
}

.current-price {
  font-size: 2.25rem;
  margin-bottom: -8px;
}

.current-change {
  margin-left: 0.2em;
  font-size: 1.2rem;
  font-weight: 600;
}

.company-links {
  margin-top: auto;
  white-space: nowrap;
  font-size: small;
}

.company-links a {
  color: #1e7e34;
}

.v-divider {
  color: #aaa;
}

.divider {
  margin: 15px 0 5px;
}

@media (max-width: 575.98px) {
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

@media (max-width: 575.98px) {
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
</style>

<script>
import Dygraph from './Dygraph'
import Heading from './Heading'
import PeriodNav from './PeriodNav'
import PageNotFound from './PageNotFound'

export default {
  components: {
    Dygraph,
    Heading,
    PeriodNav,
    PageNotFound
  },

  props: {
    ticker: {
      type: String,
      required: true
    },
    period: {
      type: String,
      default: '1d'
    },
    summaryData: {
      type: Object,
      default: null
    },
    companies: {
      type: Object,
      required: true
    }
  },

  data() {
    return {
      data: null,
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
        }
      ]
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
        data[period] = this.summaryData[period].find(
          row => row.ticker === this.ticker
        )
        return data
      }, {})
    },
    currentPrice() {
      return this.summary.period_1d.curr
    },
    currentChange() {
      return this.summary.period_1d.change
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
    currentItems() {
      return [this.currentSummary]
    },
    isCurrentHigh() {
      return this.currentPrice === this.currentSummary.high && this.currentPrice >= 30
    },
    summaryTables() {
      return [
        { class: 'summary-tables', keys: this.currentKeys },
        { class: 'summary-tables-compact', keys: this.currentKeysCompact }
      ]
    },
    currentKeys() {
      if (this.period === 'all') {
        return [['median'], ['high', 'low'], ['avg', 'sd']]
      }
      return [['volume', 'open', 'change'], ['high', 'low', 'avg'], ['sd', 'median', 'avg']]
    },
    currentKeysCompact() {
      if (this.period === 'all') {
        return [['median', 'sd'], ['high', 'low', 'avg']]
      }
      return [['volume', 'open', 'change', 'sd'], ['high', 'low', 'avg', 'median']]
    }
  },

  watch: {
    ticker: {
      handler() {
        this.updateInputs()
      },
      immediate: true
    },
    period: {
      handler() {
        this.updateInputs()
      },
      immediate: true
    }
  },

  created() {
    Shiny.addCustomMessageHandler('stock-prices', msg => {
      this.data = msg.data
    })

    $(document).on('shiny:connected', () => {
      this.updateInputs()
    })
  },

  methods: {
    updateInputs() {
      if (!window.Shiny || !window.Shiny.onInputChange) return

      // clear data to prevent graph flickering when switching tickers
      this.data = null

      Shiny.onInputChange('stock_price', {
        ticker: this.ticker,
        period: this.period
      })
    },
    numChangeClass(val) {
      if (val > 0) return 'num-positive'
      if (val < 0) return 'num-negative'
      return 'num-zero'
    },
    formatNum(val) {
      if (val >= 0) return '+' + val
      return val
    },
    formatDate(val) {
      const date = new Date(val.item.time_high)
      return date.toLocaleString() + ' NST'
    }
  }
}
</script>