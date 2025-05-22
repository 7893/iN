# 🧩 事件驱动架构示例订阅者：日志增强 GCP Cloud Function (架构版本 2025年5月21日 - 方案A)

## 🎯 目标

作为事件驱动架构（基于 GCP Pub/Sub）的一个示例订阅者，`log-enhancer-function` (部署为 GCP Cloud Function 或 Cloud Run 服务) 用于消费核心任务链中产生的业务事件，并生成更丰富的、聚合的日志记录到 Google Cloud Logging，或用于触发其他旁路通知。

## 🧱 架构角色

- **订阅的 Pub/Sub 主题**: 例如一个名为 `in-pubsub-topic-business-events` 的专用 Pub/Sub 主题。核心处理流程中的关键步骤完成后，可选择性地向此主题发布业务事件。
- **消费的事件类型**: 例如 `image.downloaded`, `metadata.extracted`, `ai.analyzed` (事件结构遵循 `event-schema-spec-*.md` 中定义的 `INEvent<T, P>`)。
- **部署形式**: Google Cloud Function (事件驱动型) 或 Cloud Run 服务。
- **输出**: 增强的、结构化的 JSON 日志到 **Google Cloud Logging**。也可能触发其他动作。

## 🧪 核心事件格式回顾（来自 `packages/shared-libs/events/types.ts`)

```typescript
// packages/shared-libs/events/types.ts (关键结构摘录)

export type INEventType = /* ...各种事件类型... */;

export interface INEvent<T_EventType extends INEventType, P_Payload = unknown> {
  eventId: string;
  type: T_EventType;
  timestamp: number;
  traceId: string;
  taskId: string;
  sourceService: string;
  dataVersion?: string;
  payload: P_Payload;
}