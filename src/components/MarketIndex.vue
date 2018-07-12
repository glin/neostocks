<template>
  <div>
    <Dygraph :data="data" :series-labels="seriesLabels" />
  </div>
</template>

<script>
import Dygraph from './Dygraph'

export default {
  components: {
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