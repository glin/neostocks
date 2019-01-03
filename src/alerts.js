import companies from './companies'
import { sendNotification } from './notifications'

const HIGH_MESSAGES = {
  all: 'All-time high!',
  '1m': '1 month high',
  '5d': '5 day high',
  '1d': '1 day high'
}

export function getPriceAlerts(summaryData, filters = {}) {
  if (
    filters.minPrice == null &&
    filters.maxPrice == null &&
    filters.exactPrice == null &&
    filters.highPeriod == null
  ) {
    return []
  }

  const filteredData = filterSummaryData(summaryData, filters)
  const alertsByTicker = filteredData.period_all.reduce((obj, data) => {
    const alert = {
      ticker: data.ticker,
      curr: data.curr,
      highPeriods: [],
      updateTime: data.update_time,
      updateTimeNST: data.update_time_nst,
      updateTimestamp: new Date(data.update_time).getTime(),
      title: `${data.ticker} at ${data.curr}`,
      icon: companies[data.ticker].logo,
      tag: data.ticker,
      location: { path: '/tickers/' + data.ticker }
    }
    return { ...obj, [data.ticker]: alert }
  }, {})

  const periods = ['1d', '5d', '1m', 'all']
  periods.forEach(period => {
    filteredData[`period_${period}`].forEach(data => {
      if (isCurrentHigh(data)) {
        alertsByTicker[data.ticker].highPeriods.push(period)
        alertsByTicker[data.ticker].message = HIGH_MESSAGES[period]
      }
    })
  })

  let alerts = Object.values(alertsByTicker)
  if (filters.highPeriod) {
    alerts = alerts.filter(alert => alert.highPeriods.includes(filters.highPeriod))
  }
  return alerts
}

function filterSummaryData(summaryData, filters = {}) {
  const { minPrice, maxPrice, exactPrice, includeTickers, excludeTickers, includeIndex } = filters

  const tickers = summaryData.period_all
    .filter(data => {
      if (!includeIndex && data.ticker === 'NEODAQ') {
        return false
      }
      if (excludeTickers && excludeTickers.length > 0 && excludeTickers.includes(data.ticker)) {
        return false
      }
      if (includeTickers && includeTickers.length > 0 && !includeTickers.includes(data.ticker)) {
        return false
      }
      if (minPrice != null && data.curr < minPrice) {
        return false
      }
      if (maxPrice != null && data.curr > maxPrice) {
        return false
      }
      if (exactPrice != null && data.curr != exactPrice) {
        return false
      }
      return true
    })
    .map(data => data.ticker)

  const filteredData = Object.keys(summaryData).reduce((filtered, period) => {
    filtered[period] = summaryData[period].filter(data => tickers.includes(data.ticker))
    return filtered
  }, {})

  return filteredData
}

function isCurrentHigh(data) {
  return data.curr === data.high && data.curr >= 30
}

export function sendNotifications(alerts, { onRead, maxShown = 2 }) {
  if (alerts.length > maxShown) {
    // Collapse all alerts into one, showing titles only
    const numAlerts = alerts.length
    const messages = alerts.map(alert => alert.title).join('\n')
    alerts = [
      {
        title: `${numAlerts} new ${numAlerts > 1 ? 'alerts' : 'alert'}`,
        message: messages,
        icon: require('./assets/neostocks.png'),
        tag: 'neostocks'
      }
    ]
  }

  alerts.forEach(alert => {
    const title = alert.title
    const options = {
      body: alert.message,
      icon: alert.icon,
      tag: alert.tag,
      badge: require('./assets/neostocks-badge.png'),
      data: alert.data
    }

    const notification = sendNotification(title, options)

    if ('onclick' in notification) {
      notification.onclick = () => {
        notification.close()
        onRead()
        window.focus()
      }
    }
  })
}
