// src/logger.test.ts
import { describe, it, expect, vi } from 'vitest'
import { logger } from './logger'

describe('logger', () => {
  it('should output structured info log', () => {
    const spy = vi.spyOn(console, 'log').mockImplementation(() => {})
    logger.info('test log', { traceId: 'abc123', worker: 'test-worker' }, { foo: 'bar' })

    expect(spy).toHaveBeenCalledTimes(1)

    const output = JSON.parse(spy.mock.calls[0][0])
    expect(output.message).toBe('test log')
    expect(output.level).toBe('info')
    expect(output.traceId).toBe('abc123')
    expect(output.worker).toBe('test-worker')
    expect(output.details).toEqual({ foo: 'bar' })

    spy.mockRestore()
  })
})

