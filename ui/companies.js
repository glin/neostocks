import companies from './companies.json'

const STOCK_BUY_URL = 'http://www.neopets.com/stockmarket.phtml?type=buy&ticker='
const COMPANY_PROFILE_URL = 'http://www.neopets.com/stockmarket.phtml?type=profile&company_id='

function getCompanyData() {
  Object.keys(companies).forEach(ticker => {
    const company = companies[ticker]
    company.logo = require(`./assets/logos/${company.logo_id}.png`)
    company.buyUrl = STOCK_BUY_URL + ticker
    company.profileUrl = COMPANY_PROFILE_URL + company.id
  })

  companies['NEODAQ'] = {
    company: 'Neopian Stock Market',
    logo: require('./assets/logos/nigel.png'),
    index: true
  }

  return companies
}

export default getCompanyData()
