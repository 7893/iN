# iN 项目基础设施资源清单与职责 (按实施优先级)

**当前时间:** 2025年4月10日 星期四 下午 06:44:48 KST  
**地点:** 韩国

以下是根据最终架构设计和实施优先级，列出的需要建立的基础设施资源名称及其详细的核心职责说明。

---

## 阶段 0/1: 核心基础与任务入口 (必需 - Required)
这些是启动项目、能够接收请求并开始一个（骨架）任务流程所必需的最基础资源。

### Workers

#### api-gateway-worker (必需)
**职责:**
- API 统一入口；处理路由。
- 执行入口处统一认证 (调用 `shared-libs/auth.ts` 实现 JWT/HMAC 验证)。
- 初始化 TraceID (调用 `shared-libs/trace.ts` 生成或提取)。
- 执行速率限制。
- 记录入口请求/响应日志 (使用 `shared-libs/logger.ts`)。

#### config-api-worker (必需)
**职责:**
- 处理用户下载配置相关的 CRUD API 请求。
- 使用 `logger.ts` 并处理 traceId (`trace.ts`)。

#### config-worker (必需)
**职责:**
- 根据配置调度后台任务。
- 初始化 Task Coordinator DO 状态。
- 推送任务到起始队列 (ImageDownloadQueue)。
- 使用 `logger.ts` 并生成/处理 traceId (`trace.ts`)。

---

### Queues (+DLQs)

#### ImageDownloadQueue / ImageDownloadQueue_DLQ (必需)
**职责:** 缓冲并传递图片下载任务指令，连接 Config Worker 到 Download Worker。

#### MetadataProcessingQueue / MetadataProcessingQueue_DLQ (必需)
**职责:** 缓冲并传递元数据提取任务指令，连接 Download Worker 到 Metadata Worker。

#### AIProcessingQueue / AIProcessingQueue_DLQ (必需)
**职责:** 缓冲并传递 AI 分析任务指令，连接 Metadata Worker 到 AI Worker。

---

### Durable Objects (Binding)

#### TASK_COORDINATOR_DO_BINDING (必需)
**职责:** 提供单个任务跨异步步骤的强一致状态跟踪和协调 (按 taskId 分片实例化)。

---

### Storage

#### iN_R2_Bucket (必需)
**职责:** 存储所有原始图片文件。

#### iN_D1_Database (必需)
**职责:** 存储结构化数据（用户信息、图片元数据基础表、AI 结果文本、配置、任务摘要等）。

---

### Other Services

#### Cloudflare Pages (in-pages) (必需)
**职责:** 托管和全球分发 frontend 静态应用（初始可为测试页）。

#### Cloudflare Secrets Store (必需)
**职责:** 集中、安全地存储和管理所有敏感凭证 (相关 Worker 按需访问)。

---

## 阶段 2: 骨架流程与可观测性 (必需 - Required)

### Workers

#### download-worker (必需)
**职责:**
- 从 ImageDownloadQueue 接收任务。
- 下载原始图片并写入 R2（不做图像处理）。
- 调用 `shared-libs/task.ts` 更新 DO 状态。
- 推送任务到 MetadataProcessingQueue。
- 使用 `logger.ts` 和 traceId。

#### metadata-worker (必需)
**职责:**
- 从 MetadataProcessingQueue 接收任务。
- 读取 R2 原始图片。
- 提取元数据并写入 D1。
- 更新 DO 状态。
- 推送任务到 AIProcessingQueue。
- 使用 `logger.ts` 和 traceId。

#### ai-worker (必需)
**职责:**
- 从 AIProcessingQueue 接收任务。
- (骨架阶段模拟 AI 调用)。
- 结果写入 D1/Vectorize。
- 更新 DO 最终状态。
- 使用 `logger.ts` 和 traceId。

---

### Other Services

#### Cloudflare Logpush (iN_Logpush_Job_Axiom) (必需)
**职责:** 将所有 Workers 产生的结构化 JSON 日志自动、实时地推送到指定日志平台 (Axiom 等)。

---

## 阶段 3: 完整核心功能 (必需 - Required)

### Workers

#### user-api-worker (必需)
**职责:** 处理用户账户 API 请求，使用 `logger.ts` 和 traceId。

#### image-query-api-worker (必需)
**职责:** 处理图片列表、详情、状态查询 API，请求日志与 traceId。

#### image-mutation-api-worker (必需)
**职责:** 处理图片元数据修改、标记删除请求，使用 `logger.ts` 和 traceId。

#### image-search-api-worker (必需)
**职责:** 处理关键词与向量搜索请求，查询 D1 与 Vectorize。

#### ai-worker (完成真实逻辑)
**新增职责:** 调用 Cloudflare AI 写入分析结果到 D1 和 Vectorize。

---

### Storage

#### iN_Vectorize_Index (必需)
**职责:** 存储图片向量 (Embeddings)，支持相似性搜索。

---

### Other Services

#### Cloudflare AI (推荐集成)
**职责:** 在 ai-worker 中调用内置模型进行图像分析。

---

## 阶段 4+: 推荐/可选功能与事件驱动

### Workers

#### notification-worker (推荐)
**职责:** 监听事件队列，发送用户通知。实现幂等性。

#### tag-indexer-worker (推荐)
**职责:** 监听事件，更新搜索标签索引。实现幂等性。

#### analytics-worker (可选)
**职责:** 收集系统与用户行为数据，用于后续分析。

#### image-update-worker (可选)
**职责:** 执行任务流聚合、清理等最终处理。

#### image-processing-worker
**当前状态:** 已取消

---

### Queues (+DLQs)

#### ImageEventsQueue / DLQ (可选)
**职责:** 广播处理里程碑事件。

#### TaskLifecycleEventsQueue / DLQ (可选)
**职责:** 广播任务整体完成/失败事件。

---

## Development & Management Tools (必需)

### Terraform (IaC)
**职责:** 统一定义、管理上述所有 Cloudflare 基础设施资源。

### Monorepo
**职责:** 组织和管理所有项目源码与逻辑模块。

---

## Shared Libraries (源码层)

- `shared-libs/logger.ts`: 日志能力
- `shared-libs/trace.ts`: 追踪能力
- `shared-libs/auth.ts`: 认证机制
- `shared-libs/task.ts`: DO 状态更新 (推荐)
- `shared-libs/events/`: 事件定义（保留）
