<template>
  <div>
    <Heading>Neodaq Index</Heading>
    <PeriodNav :period="period" />
    <Dygraph :data="data" :series-labels="seriesLabels" />
  </div>
</template>

<script>
import Heading from './Heading'
import PeriodNav from './PeriodNav'
import Dygraph from './Dygraph'

export default {
  components: {
    Heading,
    PeriodNav,
    Dygraph
  },

  props: {
    period: {
      type: String,
      default: '1d'
    },
    marketIndex: {
      type: Object,
      default: null
    }
  },

  data() {
    return {
      seriesLabels: {
        index: 'Index'
      }
    }
  },

  computed: {
    data() {
      if (!this.marketIndex) return
      const data = this.marketIndex['period_' + this.period]
      const { time, index } = data
      return { time, index }
    }
  }
}
</script>