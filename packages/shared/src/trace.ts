// packages/shared/src/trace.ts

import { nanoid } from 'nanoid'

export type TraceContext = {
  traceId: string
  taskId?: string
  worker?: string
}

/**
 * 从请求头中提取 traceId，如果不存在则生成一个。
 */
export function getOrCreateTraceId(headers: Headers): string {
  const incoming = headers.get('x-trace-id')
  return incoming && incoming.trim() !== '' ? incoming : generateTraceId()
}

/**
 * 生成新的 traceId。
 */
export function generateTraceId(): string {
  return nanoid(16)
}

