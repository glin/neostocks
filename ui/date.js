export function toDateTimeString(date) {
  if (typeof date === 'string') {
    date = new Date(date)
  }
  return date.toLocaleString()
}

export function toDateString(date) {
  if (typeof date === 'string') {
    date = new Date(date)
  }
  return date.toLocaleDateString()
}

export function toDateTimeStringNST(date) {
  if (typeof date === 'string') {
    date = new Date(date)
  }
  return date.toLocaleString('en-US', { timeZone: 'America/Los_Angeles' })
}

export function toDateStringNST(date) {
  if (typeof date === 'string') {
    date = new Date(date)
  }
  return date.toLocaleDateString('en-US', { timeZone: 'America/Los_Angeles' })
}

export function timeSince(then, now = new Date()) {
  const seconds = Math.floor((now - then) / 1000)

  let interval = Math.floor(seconds / 86400)
  if (interval > 1) {
    return interval + ' days ago'
  } else if (interval === 1) {
    return interval + ' day ago'
  }
  interval = Math.floor(seconds / 3600)
  if (interval > 1) {
    return interval + ' hours ago'
  } else if (interval === 1) {
    return interval + ' hour ago'
  }
  interval = Math.floor(seconds / 60)
  if (interval > 1) {
    return interval + ' mins ago'
  } else if (interval === 1) {
    return interval + ' min ago'
  }
  return 'just now'
}

export const HOUR = 1000 * 60 * 60
export const DAY = HOUR * 24
