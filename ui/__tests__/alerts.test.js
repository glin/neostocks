import { isValidRule } from '../alerts'

describe('isValidRule', () => {
  test('recognizes valid rules', () => {
    const rules = [
      { minPrice: 10 },
      { maxPrice: 15 },
      { exactPrice: 15 },
      { highPeriod: '1d' },
      { minPrice: 0, maxPrice: 99, highPeriod: '5d' }
    ]
    rules.forEach(rule => {
      expect(isValidRule(rule)).toBe(true)
    })
  })

  test('recognizes invalid rules', () => {
    const rules = [{}, { minPrice: null, maxPrice: null }, { price: 15 }]
    rules.forEach(rule => {
      expect(isValidRule(rule)).toBe(false)
    })
  })
})
