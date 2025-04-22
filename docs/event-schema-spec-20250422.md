# 📡 iN 项目事件结构规范  
📄 文档名称：event-schema-spec-20250422  
🗓️ 更新时间：20250422  

---

## 📦 事件驱动背景

为了实现异步副作用解耦，系统引入事件广播机制。每个阶段完成时可向事件队列推送标准结构事件，由订阅 Worker 处理。

---

## 📐 通用结构定义

```ts
export interface INEvent<T = any> {
  id: string              // 事件唯一 ID（nanoid）
  type: string            // 事件类型，如 'image.downloaded'
  taskId: string          // 关联任务 ID
  traceId?: string        // 可选链路追踪 ID
  timestamp: number       // UTC 时间戳
  payload: T              // 事件主体数据（按类型定义）
}
```

---

## 🔖 示例事件类型定义

```ts
export type INImageDownloadedPayload = {
  imageUrl: string
  size: number
  source: string
}

export type INAIAnalysisCompletedPayload = {
  tags: string[]
  vectorId: string
  confidence: number[]
}
```

---

## 📘 事件命名规范建议

- 使用小写英文 + 点号组合，如：
  - `image.downloaded`
  - `image.metadata.ready`
  - `ai.analysis.completed`

---

## ✅ 使用原则

- 所有事件必须幂等消费
- 所有订阅 Worker 使用统一结构解析
- `INEvent<T>` 必须完整，不可省略字段
