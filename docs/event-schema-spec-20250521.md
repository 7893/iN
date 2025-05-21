# 📄 event-schema-spec-20250521.md (架构版本 2025年5月21日)
📅 Updated: 2025-05-21

## 核心事件接口设计：`INEvent<T_EventType, P_Payload>` (位于 `packages/shared-libs/events/types.ts`)

所有在 iN 项目中（特别是通过 Google Cloud Pub/Sub）传递的业务事件都应遵循此核心接口结构。

```typescript
// packages/shared-libs/events/types.ts

// 定义所有可能的事件类型字符串字面量联合类型
export type INEventType =
  | "task.created"                // 任务在系统中首次创建 (可能由API GW或DO发布)
  | "task.processing.started"     // 任务开始进入核心处理流程 (可能由DO发布到首个Pub/Sub主题)
  | "image.download.initiated"    // 下载流程已启动
  | "image.downloaded"            // 图片成功下载
  | "image.download.failed"       // 图片下载失败
  | "metadata.extraction.initiated" // 元数据提取流程已启动
  | "metadata.extracted"          // 元数据成功提取
  | "metadata.extraction.failed"  // 元数据提取失败
  | "ai.analysis.initiated"       // AI分析流程已启动
  | "ai.analyzed"                 // AI分析成功完成
  | "ai.analysis.failed"          // AI分析失败
  | "task.completed"              // 整个任务成功完成 (由DO最终发布或最后一个GCP Function发布)
  | "task.failed";                // 整个任务在某个阶段失败 (由DO最终发布或错误处理逻辑发布)

// 通用事件结构
export interface INEvent<T_EventType extends INEventType, P_Payload = unknown> {
  eventId: string;      // 事件的唯一ID (例如 UUID v4)
  type: T_EventType;    // 事件类型，来自 INEventType
  timestamp: number;    // 事件发生时的 Unix 毫秒时间戳
  traceId: string;      // 全链路追踪ID，用于关联日志和跨服务调用
  taskId: string;       // 与此事件关联的核心业务任务ID
  sourceService: string; // 发布此事件的服务名称 (例如: 'cf-api-gateway-worker', 'gcp-download-function', 'cf-task-coordinator-do')
  dataVersion?: string; // 事件负载(payload)的模式版本，可选，默认为 "1.0"
  payload: P_Payload;   // 事件相关的具体数据负载
}