<template>
  <div ref="el" :style="style" />
</template>

<script>
import Dygraph from 'dygraphs/index.es5'
import 'dygraphs/dist/dygraph.min.css'

export default {
  props: {
    data: {
      type: Object,
      default: null
    },
    width: {
      type: String,
      default: '100%'
    },
    height: {
      type: String,
      default: '100%'
    },
    options: {
      type: Object,
      default: () => {}
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
    data() {
      this.render()
    },
    annotations() {
      this.setAnnotations()
    }
  },

  mounted() {
    // Don't block initial rendering
    setTimeout(this.render)
  },

  beforeDestroy() {
    if (this.g) {
      this.g.destroy()
    }
  },

  methods: {
    render() {
      if (this.data == null) {
        this.clearGraph()
        return
      }
      const csv = columnsToCsv(this.data)
      const isDateOnly = this.data.time[0].indexOf(':') < 0
      const valueFormatter = isDateOnly ? dateValueFormatter : dateTimeValueFormatter
      const options = { ...defaultOptions(valueFormatter), ...this.options }
      if (!this.g) {
        this.g = new Dygraph(this.$refs.el, csv, options)
      } else {
        // Redraw so we don't have to destroy and recreate the existing Dygraph
        this.g.updateOptions({ ...options, file: csv })
      }
      this.setAnnotations()
    },
    clearGraph() {
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
    gridLineColor: 'rgb(232, 232, 232)',
    axes: {
      x: {
        axisLineColor: 'rgb(200, 200, 200)',
        valueFormatter,
        drawGrid: false
      },
      y: {
        axisLabelWidth: 32,
        axisLineColor: 'rgba(0, 0, 0, 0)',
        axisTickSize: 6
      }
    },
    xRangePad: 4,
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

<style lang="scss">
@import '../assets/scss/variables';

.dygraph-legend {
  position: static;
  float: right;
  margin-right: 40px;
  width: auto;
}

.dygraph-axis-label {
  color: $gray-700;
}

.dygraph-axis-label-y {
  margin-top: -3px;
}

@include media-breakpoint-down(xs) {
  .dygraph-legend {
    margin-right: 10px;
  }
}
</style>