<template>
  <div>
    <Dygraph :data="data" />
  </div>
</template>

<script>
import Dygraph from './Dygraph'

export default {
  components: {
    Dygraph
  },

  props: {
    id: {
      default: 'AAVL',
      type: String
    },
    period: {
      default: '1d',
      type: String
    }
  },

  data() {
    return {
      data: null
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
        ticker: this.id,
        period: this.period
      })
    }
  }
}
</script>