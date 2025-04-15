// src/logger.ts

type LogLevel = 'debug' | 'info' | 'warn' | 'error'

export interface INLoggerContext {
  traceId?: string
  taskId?: string
  worker?: string
}

export interface INLogEntry {
  timestamp: string
  level: LogLevel
  message: string
  traceId?: string
  taskId?: string
  worker?: string
  details?: Record<string, unknown>
  error?: { message: string; stack?: string }
}

function log(level: LogLevel, message: string, context: INLoggerContext = {}, extra?: Partial<INLogEntry>) {
  const entry: INLogEntry = {
    timestamp: new Date().toISOString(),
    level,
    message,
    ...context,
    ...extra,
  }
  console.log(JSON.stringify(entry))
}

export const logger = {
  debug: (msg: string, ctx?: INLoggerContext, extra?: object) => log('debug', msg, ctx, { details: extra }),
  info: (msg: string, ctx?: INLoggerContext, extra?: object) => log('info', msg, ctx, { details: extra }),
  warn: (msg: string, ctx?: INLoggerContext, extra?: object) => log('warn', msg, ctx, { details: extra }),
  error: (msg: string, ctx?: INLoggerContext, err?: unknown, extra?: object) => {
    const error =
      err instanceof Error
        ? { message: err.message, stack: err.stack }
        : typeof err === 'string'
        ? { message: err }
        : undefined

    log('error', msg, ctx, { error, details: extra })
  },
}

