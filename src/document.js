export function updateDocumentTitle({ newPageTitle = null, newUnreadCount = null }) {
  // Document title format: (unreadCount) pageTitle - docTitle
  const match = document.title.match(/^(\(\d+\) )?(.+ - )?(.+)/)
  let [unreadCount = '', pageTitle = '', docTitle = ''] = match.slice(1)

  if (newUnreadCount != null) {
    unreadCount = newUnreadCount > 0 ? `(${newUnreadCount}) ` : ''
  }

  if (newPageTitle != null) {
    pageTitle = newPageTitle.length ? `${newPageTitle} - ` : ''
  }

  document.title = unreadCount + pageTitle + docTitle
}
