export function getLocalStore(key, initialValue = {}) {
  if (!localStorageSupported()) {
    return initialValue
  }
  let value = localStorage.getItem(key)
  if (value) {
    try {
      value = JSON.parse(value)
    } catch (e) {
      localStorage.removeItem(key)
    }
  }
  const store = { ...initialValue, ...value }
  const proxy = createLocalStorageProxy(key)
  return new Proxy(store, proxy)
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
