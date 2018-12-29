<template>
  <div
    ref="chart"
    class="chart"
  />
</template>

<style scoped>
.chart {
  height: 100%;
}
</style>

<style>
.tooltip-name {
  color: #495057;
  font-size: 0.8rem;
  line-height: 1.7;
}

.tooltip-label {
  margin-right: 15px;
}
</style>

<script>
const echarts = require('echarts/lib/echarts')
require('echarts/lib/chart/bar')
require('echarts/lib/component/tooltip')
require('echarts/lib/component/title')

export default {
  props: {
    chartData: {
      type: Array,
      default: () => []
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
      default: null
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
      type: Array,
      default: () => ['#3398DB']
    }
  },

  data() {
    return {
      chart: null
    }
  },

  mounted() {
    this.chart = echarts.init(this.$refs.chart)

    const options = {
      color: this.color,
      tooltip: {
        trigger: 'axis',
        axisPointer: {
          type: 'shadow'
        },
        backgroundColor: 'rgba(255, 255, 255, 0.925)',
        borderWidth: 1,
        borderColor: '#bbb',
        padding: 10,
        textStyle: {
          color: '#212529'
        },
        formatter: params => {
          const { name, value, seriesName, marker } = params[0]
          return `
            <div class="tooltip-name">${this.tooltipNameFormatter(name)}</div>
            ${marker}
            ${this.xAxisName == null ? `<span class="tooltip-label">${this.xAxisName}</span>` : ''}
            <span class="tooltip-value">${this.tooltipValueFormatter(value[seriesName])}</span>
          `
        }
      },
      dataset: {
        source: this.chartData
      },
      grid: {
        left: this.yAxisName ? '5%' : '3%',
        right: '4%',
        top: '3%',
        bottom: this.xAxisName ? '8%' : '3%',
        containLabel: true
      },
      xAxis: [
        {
          type: 'category',
          name: this.xAxisName,
          nameLocation: 'center',
          nameTextStyle: {
            padding: [12, 0]
          },
          axisLabel: {
            formatter: this.xAxisLabelFormatter
          },
          axisTick: {
            show: false
          }
        }
      ],
      yAxis: {
        name: this.yAxisName,
        nameLocation: 'center',
        nameGap: 50,
        axisLabel: {
          formatter: this.yAxisLabelFormatter
        },
        splitLine: {
          lineStyle: {
            color: 'rgb(232, 232, 232)'
          }
        }
      },
      series: [
        {
          type: 'bar',
          barWidth: '90%'
        }
      ]
    }

    this.chart.setOption(options)

    window.addEventListener('resize', this.handleChartResize)
  },

  beforeDestroy() {
    if (this.chart) {
      this.chart.dispose()
    } 
    window.removeEventListener('resize', this.handleChartResize)
  },

  methods: {
    handleChartResize() {
      this.chart.resize()
    }
  }
}
</script>