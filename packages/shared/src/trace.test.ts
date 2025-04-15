// packages/shared/src/trace.test.ts

import { describe, it, expect } from 'vitest'
import { generateTraceId, getOrCreateTraceId } from './trace'

describe('trace.ts', () => {
  it('generates a new traceId', () => {
    const id = generateTraceId()
    expect(id).toBeDefined()
    expect(id.length).toBeGreaterThan(5)
  })

  it('gets existing traceId from headers', () => {
    const headers = new Headers({ 'x-trace-id': 'abc123' })
    expect(getOrCreateTraceId(headers)).toBe('abc123')
  })

  it('generates traceId if header is missing', () => {
    const headers = new Headers()
    const traceId = getOrCreateTraceId(headers)
    expect(traceId).toBeDefined()
    expect(traceId.length).toBeGreaterThan(5)
  })
})

