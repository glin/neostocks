<template>
  <div class="chart-wrapper">
    <canvas ref="chart" />
  </div>
</template>

<style scoped>
.chart-wrapper {
  width: 100%;
  height: 100%;
}
</style>

<style>
</style>

<script>
// Non-bundle build since we don't need the time axis
import Chart from 'chart.js/dist/Chart.min'

export default {
  props: {
    chartData: {
      type: Array,
      required: true
    },
    xAxisName: {
      type: String,
      default: ''
    },
    xAxisLabelFormatter: {
      type: Function,
      default: value => value
    },
    yAxisName: {
      type: String,
      default: ''
    },
    yAxisLabelFormatter: {
      type: Function,
      default: value => value
    },
    tooltipNameFormatter: {
      type: Function,
      default: null
    },
    tooltipValueFormatter: {
      type: Function,
      default: null
    },
    color: {
      type: String,
      default: '#3398db'
    }
  },

  data() {
    return {
      chart: null
    }
  },

  mounted() {
    const keys = Object.keys(this.chartData[0])
    const labels = this.chartData.map(item => item[keys[0]])
    const data = this.chartData.map(item => item[keys[1]])

    // Show tooltip anywhere on the chart
    Chart.Tooltip.positioners.cursor = function(chartElements, coordinates) {
      return coordinates
    }

    // Add a shaded cursor to tooltips
    Chart.defaults.BarWithCursor = Chart.defaults.bar
    Chart.controllers.BarWithCursor = Chart.controllers.bar.extend({
      draw: function(ease) {
        Chart.controllers.bar.prototype.draw.call(this, ease)

        if (this.chart.tooltip._active && this.chart.tooltip._active.length) {
          const activePoint = this.chart.tooltip._active[0]
          const ctx = this.chart.ctx
          const x = activePoint.tooltipPosition().x
          const topY = this.chart.scales['y-axis-0'].top
          const bottomY = this.chart.scales['y-axis-0'].bottom
          const barWidth = activePoint._model.width
          const cursorWidth = barWidth / this._ruler.scale.options.categoryPercentage
          ctx.save()
          ctx.beginPath()
          ctx.moveTo(x, topY)
          ctx.lineTo(x, bottomY)
          ctx.lineWidth = cursorWidth
          ctx.strokeStyle = '#eee'
          // Use compositing to draw behind the bar
          ctx.globalCompositeOperation = 'destination-over'
          ctx.stroke()
          ctx.restore()
        }
      }
    })

    this.chart = new Chart(this.$refs.chart, {
      type: 'BarWithCursor',
      data: {
        labels,
        datasets: [
          {
            data,
            backgroundColor: this.color
          }
        ]
      },
      options: {
        tooltips: {
          mode: 'index',
          intersect: false,
          position: 'cursor',

          caretPadding: 24,
          caretSize: 0,

          xPadding: 12,
          yPadding: 12,
          cornerRadius: 3,

          backgroundColor: 'rgba(255, 255, 255, 0.925)',
          borderColor: '#888',
          borderWidth: 0.7,

          titleFontFamily: 'Open Sans',
          titleFontSize: 13,
          titleFontColor: '#212529',
          titleFontStyle: 'normal',

          bodyFontFamily: 'Open Sans',
          bodyFontSize: 15,
          bodyFontColor: '#212529',
          bodyFontStyle: 'bold',

          callbacks: {
            title: tooltipItem => {
              return this.tooltipNameFormatter
                ? this.tooltipNameFormatter(tooltipItem[0].xLabel)
                : tooltipItem[0].xLabel
            },
            label: tooltipItem => {
              const padding = ' '
              const label = this.tooltipValueFormatter
                ? this.tooltipValueFormatter(tooltipItem.yLabel)
                : tooltipItem.yLabel
              return padding + label
            }
          }
        },
        hover: {
          // Hover anywhere on the chart to match the cursor
          mode: 'x',
          intersect: false
        },
        layout: {
          padding: {
            top: 8,
            bottom: 0
          }
        },
        scales: {
          xAxes: [
            {
              barThickness: 'flex',
              barPercentage: 0.9,
              categoryPercentage: 0.9,
              gridLines: {
                display: false
              },
              scaleLabel: {
                display: this.xAxisName,
                labelString: this.xAxisName,
                fontFamily: 'Open Sans'
              },
              ticks: {
                autoSkipPadding: 3,
                fontSize: 13,
                fontFamily: 'Open Sans',
                maxRotation: 0,
                callback: this.xAxisLabelFormatter
              }
            }
          ],
          yAxes: [
            {
              scaleLabel: {
                display: this.yAxisName,
                fontFamily: 'Open Sans',
                labelString: this.yAxisName
              },
              ticks: {
                beginAtZero: true,
                fontFamily: 'Open Sans',
                fontSize: 13,
                maxTicksLimit: 6,
                callback: this.yAxisLabelFormatter
              }
            }
          ]
        },
        legend: {
          display: false
        },
        animation: {
          duration: 0
        },
        // Needed for proper resizing
        maintainAspectRatio: false
      }
    })
  },

  beforeDestroy() {
    if (this.chart) {
      this.chart.destroy()
    }
  }
}
</script>