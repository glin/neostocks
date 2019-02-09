import { updateDocumentTitle } from '../document'

describe('updateDocumentTitle', () => {
  afterEach(() => {
    document.getElementsByTagName('html')[0].innerHTML = ''
  })

  test('updates page title', () => {
    document.title = 'neostocks'
    const ogTitle = addMetaTag({ property: 'og:title', content: 'page - neostocks' })
    updateDocumentTitle({ newPageTitle: 'new' })
    expect(document.title).toEqual('new - neostocks')
    expect(ogTitle.content).toEqual('new - neostocks')
  })

  test('does not update title', () => {
    document.title = 'neostocks'
    const ogTitle = addMetaTag({ property: 'og:title', content: 'neostocks' })
    updateDocumentTitle({ newUnread: false })
    expect(document.title).toEqual('neostocks')
    expect(ogTitle.content).toEqual('neostocks')
  })

  test('updates unread indicator', () => {
    document.title = 'page - neostocks'
    const ogTitle = addMetaTag({ property: 'og:title', content: 'page - neostocks' })
    updateDocumentTitle({ newUnread: true })
    expect(document.title).toEqual('* page - neostocks')
    expect(ogTitle.content).toEqual('page - neostocks')
  })

  test('updates page title with unread indicator', () => {
    document.title = 'page - neostocks'
    const ogTitle = addMetaTag({ property: 'og:title', content: 'page - neostocks' })
    updateDocumentTitle({ newPageTitle: 'bloo', newUnread: true })
    expect(document.title).toEqual('* bloo - neostocks')
    expect(ogTitle.content).toEqual('bloo - neostocks')
  })
})

function addMetaTag(attrs) {
  const meta = document.createElement('meta')
  Object.keys(attrs).forEach(name => meta.setAttribute(name, attrs[name]))
  document.getElementsByTagName('head')[0].appendChild(meta)
  return meta
}
