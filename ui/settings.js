import { getLocalStore } from './storage'

const SETTINGS_KEY = 'settings'

const DEFAULT_SETTINGS_STORE = {
  enableDesktopNotifications: false,
  lastReadTimestamp: null,
  alerts: [
    {
      condition: 'above'
    }
  ]
}

export function getSettingsStore() {
  return getLocalStore(SETTINGS_KEY, DEFAULT_SETTINGS_STORE)
}
