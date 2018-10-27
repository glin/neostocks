export function sendNotification(title, options) {
  return new Notification(title, options)
}

export function requestPermission() {
  if (!notificationsSupported()) {
    return new Promise(resolve => resolve(false))
  }

  const granted = Notification.requestPermission().then(permission => {
    return permission === 'granted'
  })

  return granted
}

export function notificationsSupported() {
  return 'Notification' in window
}

export function notificationsEnabled() {
  return Notification.permission === 'granted'
}

export function notificationsBlocked() {
  return Notification.permission === 'denied'
}
