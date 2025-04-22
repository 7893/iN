# 🧩 shared-libs-overview-20250422.md

## 🧱 主要共享模块

| 文件 | 功能 |
|------|------|
| logger.ts | 结构化 JSON 日志记录 |
| trace.ts | traceId 生命周期管理（生成/注入/传递） |
| auth.ts | JWT 与 HMAC 签名验证逻辑 |
| task.ts | 封装 DO 状态更新辅助逻辑 |
| events/ | 定义事件结构 INEvent<T> 以及类型化事件名 |

## 🔔 INEvent<T> 结构

```ts
type INEvent<T extends string, P = unknown> = {
  type: T;
  timestamp: number;
  traceId: string;
  taskId: string;
  payload: P;
};
```

## 📦 建议事件实现位置

- **事件发布**：在 Download/Metadata/AI Worker 中处理完成后立即 `publishEvent()`
- **事件订阅者**：单独 Worker 监听事件队列（如 log-enhancer）

---

文档名：shared-libs-overview-20250422.md  
更新日期：2025-04-22
