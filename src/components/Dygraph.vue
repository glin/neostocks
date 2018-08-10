<template>
  <div ref="el" :id="id" :style="style" />
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
    id: {
      type: String,
      default: null
    },
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
    seriesLabels: {
      type: Object,
      default: null
    },
    annotation: {
      type: Object,
      default: null
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
    annotation() {
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

        // copy data before mutating it
        let data = { ...this.data }

        const isDateTime = data.time[0].indexOf(':') > 0

        if (!isNaN(data.time[0])) {
          data.time = data.time.map(timeSec => new Date(timeSec * 1000))
        }

        if (this.seriesLabels) {
          const keys = Object.keys(data)
          data = keys.reduce((newData, key) => {
            const label = this.seriesLabels[key] ? this.seriesLabels[key] : key
            newData[label] = data[key]
            return newData
          }, {})
        }
        const csv = dataFrameToCSV(data)
        const valueFormatter = isDateTime ? dateTimeValueFormatter : dateValueFormatter
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
      const annotations = this.annotation ? [this.annotation] : []
      this.g.setAnnotations(annotations)
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

function dataFrameToCSV(data) {
  const headers = Object.keys(data)
  const csv = [headers.join(',')]
  const numRows = data[headers[0]].length
  for (let i = 0; i < numRows; i++) {
    const row = headers.map(header => {
      const val = data[header][i]
      return val != null ? val : ''
    })
    csv.push(row.join(','))
  }
  return csv.join('\n')
}
</script>