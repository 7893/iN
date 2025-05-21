# 📊 Cloudflare Logpush 及 GCP 服务日志接入 Google Cloud Logging 指南 (架构版本 2025年5月21日)
📄 文档名称：logpush-gcp-logging-guide-20250521.md (原 logpush-axiom-guide-20250422.md)
🗓️ 更新时间：2025-05-21

---

## 🎯 目标

通过结构化日志输出，将 Cloudflare 服务 (Workers, DO等) 的日志以及 GCP 服务 (Cloud Functions/Run, Pub/Sub, Firestore等) 和 Vercel 前端应用的日志统一接入 **Google Cloud Logging**，实现 iN 项目的**集中化、可追踪、可聚合、可告警**的日志系统。

---

## 📦 步骤一：日志结构与内容设计 (跨平台通用)

所有应用和服务（Vercel 前端、Cloudflare Workers/DO、GCP Cloud Functions/Run）输出的日志应尽可能遵循统一的结构化 JSON 格式。推荐使用 `packages/shared-libs/logger.ts` 中定义的日志工具。

**核心日志字段示例**:
```json
{
  "timestamp": "YYYY-MM-DDTHH:mm:ss.sssZ", // ISO 8601 格式时间戳
  "severity": "INFO | WARN | ERROR | DEBUG | CRITICAL", // 日志级别
  "message": "人类可读的日志信息",
  "traceId": "unique-trace-id-across-services", // 全链路追踪ID
  "taskId": "specific-task-id", // 关联的业务任务ID (如果适用)
  "serviceContext": {
    "service": "cf-api-gateway | gcp-download-function | vercel-frontend", // 服务名称
    "version": "1.0.2" // 服务版本
  },
  "httpRequest": { // (可选) 如果是HTTP请求相关的日志
    "requestMethod": "GET",
    "requestUrl": "/api/tasks",
    "status": 200,
    "userAgent": "...",
    "remoteIp": "..."
  },
  "error": { // (可选) 如果是错误日志
    "message": "Error message",
    "stack": "Error stack trace",
    "type": "ErrorType"
  },
  "customDimensions": { // 其他业务相关的自定义字段
    "userId": "user-abc-123",
    "imageKey": "r2/path/to/image.jpg"
  }
}

🛠️ 步骤二：Cloudflare 日志接入 Google Cloud Logging
Cloudflare Logpush 不直接支持推送到 Google Cloud Logging。常用的方法是通过中间服务或存储：

方案 A: Logpush -> Google Cloud Pub/Sub -> Cloud Function -> Cloud Logging (推荐)

创建 GCP Pub/Sub 主题: 例如 in-pubsub-topic-cf-logs。
创建 Cloudflare Logpush Job:
在 Cloudflare 控制台或通过 API/Terraform 创建 Logpush 作业。
目标类型选择: HTTP Endpoint。
目标地址: 一个专门用于接收日志的、由 GCP Cloud Function 提供的 HTTP 端点 URL (此 Function 再将日志写入 Pub/Sub，或直接写入 Cloud Logging，但写入 Pub/Sub 更解耦)。
或者，如果 Logpush 支持直接向 Pub/Sub 发布（需要验证 Cloudflare 是否提供此原生集成或需要自定义 Worker 代理），则配置为直接发布到步骤1创建的 Pub/Sub 主题。
日志格式: 选择 JSON。
字段选择: 选择需要的 Cloudflare 日志字段，确保包含 traceId (如果通过 HTTP Header 传递给 Worker 并由 Worker 记录)。
认证: 配置 Logpush 请求到 GCP Function HTTP 端点所需的认证机制 (例如，GCP Function 要求特定的 Auth Token)。
创建 GCP Cloud Function (log-forwarder-function):
触发器: HTTP 触发器（如果 Logpush 推送到 HTTP Endpoint）或 Pub/Sub 触发器（如果 Logpush 能直接发到 Pub/Sub，或者上一步的 HTTP Function 将日志转发到另一个 Pub/Sub 主题）。
逻辑: 接收来自 Logpush 的日志数据，进行必要的格式转换（确保符合 Cloud Logging 的结构化日志期望），然后使用 @google-cloud/logging SDK 或简单的 console.log(JSON.stringify(logEntry)) 将日志写入 Google Cloud Logging。
方案 B: Logpush -> Google Cloud Storage (GCS) -> Cloud Logging (通过日志接收器 Sink)

创建 GCS Bucket: 例如 in-gcs-bucket-cf-logs。
创建 Cloudflare Logpush Job:
目标类型选择: Google Cloud Storage。
配置 GCS Bucket 名称、凭证等。
日志格式选择 JSON。
创建 Google Cloud Logging Sink:
在 Cloud Logging 中配置一个日志接收器 (Sink)。
目标: 选择步骤1创建的 GCS Bucket。
过滤器: (可选) 指定只导入特定格式或包含特定字段的日志文件。
Cloud Logging 会自动监控该 GCS Bucket 并导入新的日志文件。
🛠️ 步骤三：GCP 服务日志接入 (自动)
Google Cloud Functions, Cloud Run, Pub/Sub, Firestore 等 GCP 服务:
默认情况下，这些服务产生的日志 (例如通过 console.log, console.error 在 Node.js 函数中输出的内容，或服务自身的审计日志) 会自动收集到 Google Cloud Logging 中。
确保这些服务输出的日志也是结构化的 JSON，包含 traceId, taskId 等关键字段，以便于统一查询和分析。
🎨 步骤四：Vercel 前端应用日志接入
方案 A (客户端日志库推送到自定义API):
在 Vercel 前端应用中使用一个客户端日志库 (例如 Sentry (有免费额度), Logtail, 或自建简单方案)。
将客户端错误和关键性能指标/用户行为日志发送到一个专门的 Cloudflare Worker API 端点。
该 Worker API 端点再将这些日志转发到 Google Cloud Logging (例如通过上述 Logpush to Pub/Sub to Logging 的类似机制)。
方案 B (Vercel Log Drains - 通常为付费功能):
Vercel 的付费计划可能提供 Log Drains 功能，可以将 Vercel 平台的日志（构建日志、函数日志等）直接导出到第三方日志服务，可能包括 GCP Cloud Logging 或兼容的中间服务。需检查 Vercel 当前支持的集成和费用。
对于免费方案，方案 A 更可行。
🔎 步骤五：在 Google Cloud Logging 中验证、查询与可视化
验证: 触发一些操作后，在 Google Cloud Logging (Logs Explorer) 中检查是否能看到来自 Vercel, Cloudflare 和 GCP 各组件的日志。
查询:
使用 Logs Explorer 的查询语言按 traceId 过滤，查看完整调用链路的日志。
按 taskId, serviceContext.service, severity 等字段进行过滤和分析。
指标与仪表盘 (Google Cloud Monitoring):
基于结构化日志中的字段创建对数指标 (Logs-based Metrics)。
在 Cloud Monitoring 中创建仪表盘，可视化关键指标：
各服务错误率。
API 请求延迟（从API Gateway到后端处理完成）。
Pub/Sub 消息处理时间和积压量。
特定任务 (taskId) 的处理耗时和状态流转。
告警 (Google Cloud Monitoring):
基于日志指标或监控指标配置告警规则：
关键服务错误率超阈值。
Pub/Sub 死信主题出现消息。
长时间未完成的任务。
✅ 推荐策略总结
统一日志格式: 所有服务输出结构化 JSON 日志，包含标准字段如 traceId, taskId, severity, serviceContext。
Cloudflare 日志: 通过 Logpush + Pub/Sub + Cloud Function 方案接入 GCP Cloud Logging。
GCP 服务日志: 自动接入 GCP Cloud Logging，确保日志内容结构化。
Vercel 前端日志: 通过自定义 API (CF Worker) 中转到 GCP Cloud Logging。
集中分析与监控: 使用 Google Cloud Logging & Monitoring 作为统一平台。
traceId 是关键: 确保 traceId 在整个请求链路中（Vercel -> Cloudflare -> GCP -> Cloudflare DO 回调等）得到正确生成和传递。
此方案旨在利用 Google Cloud Logging 强大的功能和免费额度，为多云架构的 iN 项目提供一个集中的、高效的可观测性解决方案。