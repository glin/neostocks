<template>
  <div>
    <div class="content">
      <div class="heading">
        <a :href="COMPANY_PROFILE_URL + company.id" target="_blank" rel="noopener noreferrer">
          <img :src="company.logoUrl" class="company-logo">
        </a>
        <div class="heading-text">
          <span class="company-name">{{ company.name }}</span>

          <a :href="COMPANY_PROFILE_URL + company.id" target="_blank" rel="noopener noreferrer">
            <span class="company-ticker"> {{ ticker }} </span>
          </a>

        </div>
      </div>
      <hr class="divider">
      <span class="price">{{ currentSummary.curr }}</span>
      <span :class="numClass(currentSummary.change)" class="num-change">{{ formatNum(currentSummary.change) }}</span>
    </div>
    <PeriodNav :period="period" />
    <Dygraph :data="data" />
  </div>
</template>

<style scoped>
.content {
  margin: 0 5px 10px 5px;
}

.heading {
  display: flex;
  align-items: center;
}

.company-logo {
  margin-right: 0.75em;
  width: 2.5rem;
  height: 2.5rem;
}

.company-name {
  font-size: 2rem;
}

.company-ticker {
  margin-left: 0.5em;
  font-size: 1.15rem;
  color: #6c757d;
}

.divider {
  margin: 5px 0;
}

.price {
  font-size: 1.75em;
}

.num-change {
  margin-left: 0.25em;
  font-size: 1.25rem;
}

.num-positive {
  color: green;
}

.num-negative {
  color: red;
}
</style>

<script>
import Dygraph from './Dygraph'
import PeriodNav from './PeriodNav'

export default {
  components: {
    Dygraph,
    PeriodNav
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
      COMPANY_PROFILE_URL:
        'http://www.neopets.com/stockmarket.phtml?type=profile&company_id='
    }
  },

  computed: {
    company() {
      const data = this.companies[this.ticker]
      return {
        name: data.company,
        id: data.id,
        logoUrl: '/assets/logos/' + data.logo_id + '.gif'
      }
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
    }
  },

  watch: {
    id: {
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
      if (!(window.Shiny && window.Shiny.onInputChange)) return
      Shiny.onInputChange('stock_price', {
        ticker: this.ticker,
        period: this.period
      })
    },
    numClass(val) {
      if (val > 0) return 'num-positive'
      if (val < 0) return 'num-negative'
      return
    },
    formatNum(val) {
      if (val > 0) return '+' + val
      return val
    }
  }
}
</script>