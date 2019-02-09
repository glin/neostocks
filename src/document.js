export function updateDocumentTitle({ newPageTitle = null, newUnread = null }) {
  // Document title format: * pageTitle - docTitle
  const match = document.title.match(/^(\* )?(.+ - )?(.+)/)
  let [unreadIndicator = '', pageTitle = '', docTitle = ''] = match.slice(1)

  if (newUnread != null) {
    unreadIndicator = newUnread ? `* ` : ''
  }

  if (newPageTitle != null) {
    pageTitle = newPageTitle.length ? `${newPageTitle} - ` : ''
  }

  const title = pageTitle + docTitle
  document.title = unreadIndicator + title
  document.querySelector('meta[property="og:title"]').content = title
}
