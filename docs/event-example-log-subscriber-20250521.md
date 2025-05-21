# 🧩 事件驱动架构示例订阅者：日志增强 GCP Cloud Function (架构版本 2025年5月21日)

## 🎯 目标

作为事件驱动架构（基于 GCP Pub/Sub）的一个示例订阅者，`log-enhancer-function` (部署为 GCP Cloud Function 或 Cloud Run 服务) 用于消费核心任务链中产生的业务事件，并生成更丰富的、聚合的日志记录到 Google Cloud Logging，或用于触发其他旁路通知。

## 🧱 架构角色

- **订阅的 Pub/Sub 主题**: 例如一个名为 `in-pubsub-topic-business-events` 的专用 Pub/Sub 主题。核心处理流程中的关键步骤（例如图片下载完成、元数据提取完成、AI分析完成）完成后，除了向下一个业务阶段的主题发消息，也可以选择性地向这个 `business-events` 主题发布一个副本或专门的事件消息。
    * 或者，`TaskCoordinatorDO` 在状态发生重要变更后，也可以直接发布事件到此主题。
- **消费的事件类型**: 例如 `image.downloaded`, `metadata.extracted`, `ai.analyzed` (事件结构遵循 `event-schema-spec-*.md` 中定义的 `INEvent<T, P>`)。
- **部署形式**: Google Cloud Function (事件驱动型) 或 Cloud Run 服务。
- **输出**: 增强的、结构化的 JSON 日志到 **Google Cloud Logging**。也可能触发其他动作，如发送通知到消息服务。

## 🧪 示例事件格式（来自 `packages/shared-libs/events/types.ts`)

```typescript
// packages/shared-libs/events/types.ts (部分摘录，以配合下方示例代码)

// 定义所有可能的事件类型字符串字面量联合类型
export type INEventType =
  | "task.created"
  | "task.processing.started"
  | "image.download.initiated"
  | "image.downloaded"
  | "image.download.failed"
  | "metadata.extraction.initiated"
  | "metadata.extracted"
  | "metadata.extraction.failed"
  | "ai.analysis.initiated"
  | "ai.analyzed"
  | "ai.analysis.failed"
  | "task.completed"
  | "task.failed";

// 通用事件结构
export interface INEvent<T_EventType extends INEventType, P_Payload = unknown> {
  eventId: string;      // 事件的唯一ID (例如 UUID)
  type: T_EventType;    // 事件类型，来自 INEventType
  timestamp: number;    // 事件发生时的 Unix 毫秒时间戳
  traceId: string;      // 全链路追踪ID，用于关联日志和跨服务调用
  taskId: string;       // 与此事件关联的核心业务任务ID
  sourceService: string; // 发布此事件的服务名称
  dataVersion?: string; // 事件负载(payload)的模式版本，可选，默认为 "1.0"
  payload: P_Payload;   // 事件相关的具体数据负载
}

// 示例: image.downloaded 事件负载
export interface ImageDownloadedPayload {
  originalUrl: string;
  storageProvider: "R2" | "GCS";
  imageKey: string;
  contentType: string;
  sizeBytes: number;
  downloadDurationMs: number;
  downloadedBy: string;
}

// 示例: task.failed 事件负载
export interface TaskFailedPayload {
  failedStage: Exclude<INEvenType, "task.failed" | "task.created" | "task.completed" | "task.processing.started">; // 导致整个任务失败的具体阶段事件类型
  errorCode?: string;
  errorMessage: string;
  errorDetails?: any;
}