# 🧩 shared-libs-overview-20250521.md (架构版本 2025年5月21日)

`packages/shared-libs` (或类似命名) 是 iN 项目 Monorepo 中的一个关键部分，用于存放跨多个应用（Vercel前端、Cloudflare Workers/DO、GCP Cloud Functions/Run）共享的通用逻辑、类型定义、工具函数和配置。

---

## 🎯 主要目标

- **代码复用**: 避免在不同应用中重复编写相同的逻辑。
- **类型安全**: 提供统一的 TypeScript 类型定义，确保跨应用接口的一致性。
- **标准化**: 推行项目范围内的日志记录、错误处理、事件结构等标准。
- **可维护性**: 将通用逻辑集中管理，便于修改和升级。

---

## 🧱 主要共享模块 (示例)

| 模块/文件 (在 `packages/shared-libs/src/`下) | 功能描述                                                                                                                               | 主要消费者 (示例)                                                 |
| ------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------- |
| `logger.ts`                                | 提供结构化 JSON 日志记录的工具函数。支持设置日志级别、自动附加 `traceId`, `taskId`, `serviceContext` 等通用字段。适配不同平台的日志输出 (如 Cloudflare Workers 的 `console` 和 GCP Cloud Logging 的期望格式)。 | 所有 CF Workers, DO, GCP Functions/Run, (可选) Vercel 前端API路由 |
| `trace.ts`                                 | 提供 `traceId` 的生成、传递和管理逻辑。例如，从入站请求头中提取 `traceId`，或为新请求生成 `traceId`，并确保其在后续的内部调用和 Pub/Sub 消息中传递。 | CF API Gateway Worker, GCP Functions/Run, DO                      |
| `auth.ts` (或 `gcip-helpers.ts`)             | 封装与 Google Cloud Identity Platform (GCIP) 交互的辅助逻辑。例如：<br> - (后端) 验证 GCIP ID Token 的函数 (可能需要 GCP SDK 或调用 GCIP API)。<br> - (前端) 获取和刷新 GCIP Token 的辅助函数 (如果 GCIP SDK 本身不完全满足需求)。 | CF API Gateway Worker, Vercel 前端                               |
| `task-do-client.ts` (或 `task-coordinator-client.ts`) | (可选) 封装调用 Cloudflare `TaskCoordinatorDO` 接口的客户端逻辑，例如更新状态、查询状态。便于 GCP Cloud Functions/Run 或其他 Worker 调用 DO。 | GCP Functions/Run, 其他需要与DO交互的 CF Workers                  |
| `events/types.ts`                            | 定义项目中所有业务事件的 TypeScript 类型 (`INEvenType` 联合类型) 和核心事件结构 `INEvent<T, P>` (包含 `eventId`, `type`, `timestamp`, `traceId`, `taskId`, `sourceService`, `payload` 等)。 | 所有事件的发布者和消费者 (CF Workers, GCP Functions/Run, DO)    |
| `events/payloads.ts`                         | 定义 `INEvent` 中各种具体事件类型所对应的 `payload` 的详细 TypeScript 接口。例如 `ImageDownloadedPayload`, `MetadataExtractedPayload`, `TaskFailedPayload` 等。 | 同上                                                              |
| `validators/` (例如 `task-schema.ts`)        | 使用 Zod 或类似库定义用于验证 API 请求体、Pub/Sub 消息负载等的模式 (schemas)。                                                             | CF API Gateway Worker, GCP Functions/Run (消息消费者)             |
| `utils/` (例如 `http-client.ts`, `string-utils.ts`) | 通用工具函数，如封装的 `Workspace` 客户端 (支持自动注入 `traceId` 或认证头)、字符串处理、日期处理等。                                          | 所有应用                                                          |
| `config/` (例如 `global-config.ts`)          | (可选) 存储一些项目范围内的、非敏感的、共享的配置常量。                                                                                       | 所有应用                                                          |

---

## 🔔 `INEvent<T_EventType, P_Payload>` 核心事件结构 (示例回顾)

参考 `event-schema-spec-*.md` 文档中的详细定义。
```typescript
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