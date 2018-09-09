<template>
  <div ref="el" :style="style" />
</template>

<style>
.dygraph-legend {
  position: static;
  float: right;
  margin-right: 40px;
  width: auto;
}

@media (max-width: 575.98px) {
  .dygraph-legend {
    margin-right: 10px;
  }
}
</style>

<script>
import Dygraph from 'dygraphs'

import 'dygraphs/dist/dygraph.css'

export default {
  props: {
    data: {
      type: Object,
      required: true
    },
    width: {
      type: String,
      default: '100%'
    },
    height: {
      type: String,
      default: '300px'
    },
    annotations: {
      type: Array,
      default: () => []
    }
  },

  data() {
    return {
      g: null,
      style: {
        width: this.width,
        height: this.height
      }
    }
  },

  watch: {
    annotations() {
      this.setAnnotations()
    }
  },

  mounted() {
    this.$watch(
      'data',
      () => {
        if (this.data == null) {
          this.resetGraph()
          return
        }
        const csv = columnsToCsv(this.data)
        const isDateOnly = this.data.time[0].indexOf(':') < 0
        const valueFormatter = isDateOnly ? dateValueFormatter : dateTimeValueFormatter
        this.g = renderDygraph(this.$refs.el, csv, defaultOptions(valueFormatter))
        this.setAnnotations()
      },
      { immediate: true }
    )
  },

  methods: {
    resetGraph() {
      if (!this.g) return
      const plotData = [[0, 0]]
      this.g.updateOptions({ file: plotData })
    },
    setAnnotations() {
      if (!this.g) return
      this.g.setAnnotations(this.annotations)
    }
  }
}

function defaultOptions(valueFormatter = dateTimeValueFormatter) {
  return {
    gridLineColor: 'rgb(187, 187, 187)',
    axes: {
      x: {
        valueFormatter,
        drawGrid: false
      }
    },
    colors: ['#2294ba', '#1e7e34'],
    fillGraph: true
  }
}

function dateTimeValueFormatter(d) {
  return new Date(d).toLocaleString() + ' NST'
}

function dateValueFormatter(d) {
  return new Date(d).toLocaleDateString()
}

function renderDygraph(el, data, options) {
  const g = new Dygraph(el, data, options)
  return g
}

function columnsToCsv(columns) {
  const headers = Object.keys(columns)
  const rows = [headers.join(',')]
  const numRows = columns[headers[0]].length
  for (let i = 0; i < numRows; i++) {
    const row = headers.map(header => {
      const val = columns[header][i]
      return val != null ? val : ''
    })
    rows.push(row.join(','))
  }
  return rows.join('\n')
}
</script>