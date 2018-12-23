export function sendNotification(title, options) {
  if (swNotificationsSupported()) {
    return navigator.serviceWorker.ready.then(registration => {
      return registration.showNotification(title, options)
    })
  }

  if (notificationsSupported()) {
    return new Notification(title, options)
  }
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

export function swNotificationsSupported() {
  return serviceWorkerSupported() && 'showNotification' in ServiceWorkerRegistration.prototype
}

export function serviceWorkerSupported() {
  return 'serviceWorker' in navigator
}
