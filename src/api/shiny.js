export function addMessageHandler(id, handler) {
  Shiny.addCustomMessageHandler(id, handler)
}

export function setInputValue(id, value) {
  connected().then(() => Shiny.onInputChange(id, value))
}

export function connected() {
  if (isConnected()) return Promise.resolve()
  return new Promise(resolve => {
    $(document).one('shiny:connected', e => resolve(e))
  })
}

function isConnected() {
  return Shiny.shinyapp && Shiny.shinyapp.isConnected()
}
