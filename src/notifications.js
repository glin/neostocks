export function sendNotification(title, options) {
  return new Notification(title, options)
}

export function requestPermission() {
  if (!notificationsSupported()) {
    return new Promise(resolve => resolve(false))
  }

  try {
    return Notification.requestPermission().then(permission => permission === 'granted')
  } catch (error) {
    // For browsers that don't support the promise-based syntax (e.g. Safari)
    return new Promise(resolve => {
      Notification.requestPermission(permission => resolve(permission === 'granted'))
    })
  }
}

export function notificationsSupported() {
  return 'Notification' in window
}

export function notificationsEnabled() {
  return notificationsSupported() && Notification.permission === 'granted'
}

export function notificationsBlocked() {
  return notificationsSupported() && Notification.permission === 'denied'
}
