const DEFAULT_SETTINGS = {
  enableNotifications: true,
  enableDesktopNotifications: false,
  notifyOnPeaks: false,
  notifyOnTickers: []
}

const LOCAL_STORAGE_KEY = 'settings'

export function initSettings() {
  if (!localStorageSupported()) {
    return DEFAULT_SETTINGS
  }
  const savedSettings = getLocalStorageSettings(LOCAL_STORAGE_KEY)
  const settings = { ...DEFAULT_SETTINGS, ...savedSettings }
  const proxy = createLocalStorageProxy(LOCAL_STORAGE_KEY)
  return new Proxy(settings, proxy)
}

function getLocalStorageSettings(settingsKey) {
  const savedSettings = localStorage.getItem(settingsKey)
  if (savedSettings) {
    try {
      const parsedSettings = JSON.parse(savedSettings)
      if (!parsedSettings || typeof parsedSettings !== 'object') {
        throw new Error('unexpected value for settings')
      }
      return parsedSettings
    } catch (e) {
      localStorage.removeItem(settingsKey)
    }
  }
  return {}
}

function createLocalStorageProxy(settingsKey) {
  return {
    get(obj, key) {
      return obj[key]
    },

    set(obj, key, value) {
      obj[key] = value
      localStorage.setItem(settingsKey, JSON.stringify(obj))
      return true
    }
  }
}

function localStorageSupported() {
  try {
    return 'localStorage' in window && window['localStorage'] != null
  } catch (e) {
    return false
  }
}
