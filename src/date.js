export function timeSince(then, now = new Date()) {
  const seconds = Math.floor((now - then) / 1000)

  let interval = Math.floor(seconds / 86400)
  if (interval > 1) {
    return interval + ' days'
  } else if (interval === 1) {
    return interval + ' day'
  }
  interval = Math.floor(seconds / 3600)
  if (interval > 1) {
    return interval + ' hours'
  }
  interval = Math.floor(seconds / 60)
  if (interval > 1) {
    return interval + ' mins'
  } else if (interval === 1) {
    return interval + ' min'
  }
  return 'less than 1 min'
}