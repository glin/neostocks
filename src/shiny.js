export function addMessageHandler(id, handler) {
  Shiny.addCustomMessageHandler(id, handler)
}
