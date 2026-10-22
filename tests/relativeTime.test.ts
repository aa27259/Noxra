import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

vi.mock('../src/i18n', () => ({
  t: (key: string) => (key === 'item.justNow' ? 'just now' : key === 'item.ago' ? 'ago' : key),
  getResolvedLanguage: () => 'en'
}))

import { relativeTime } from '../src/lib/format'

describe('relativeTime', () => {
  beforeEach(() => {
    vi.useFakeTimers()
    vi.setSystemTime(new Date('2026-09-04T12:00:00.000Z'))
  })

  afterEach(() => {
    vi.useRealTimers()
  })

  it('shows just now for copies under 5 seconds old', () => {
    expect(relativeTime(Date.now() - 1000)).toBe('just now')
    expect(relativeTime(Date.now())).toBe('just now')
  })

  it('does not stay on just now after a minute', () => {
    const capturedAt = Date.now() - 3 * 60 * 1000
    const label = relativeTime(capturedAt)
    expect(label.toLowerCase()).not.toContain('just now')
  })

  it('does not stay on just now after an hour', () => {
    const capturedAt = Date.now() - 2 * 60 * 60 * 1000
    const label = relativeTime(capturedAt)
    expect(label.toLowerCase()).not.toContain('just now')
  })
})
