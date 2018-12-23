self.addEventListener('install', event => {
  event.waitUntil(self.skipWaiting())
})

self.addEventListener('activate', event => {
  event.waitUntil(self.clients.claim())
})

self.addEventListener('notificationclick', event => {
  event.notification.close()

  event.waitUntil(
    self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then(clients => {
      clients.forEach(client => {
        if (event.notification.data && !event.notification.data.collapsed) {
          client.postMessage({ readNotifications: true })
        }
      })

      const isFocused = clients.some(client => client.focused)
      const targetClient = clients.find(client => 'focus' in client)
      if (!isFocused && targetClient) {
        targetClient.focus()
      }
    })
  )
})
