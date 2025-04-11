# iN 项目基础设施资源清单与职责 (按实施优先级)

**当前时间**: 2025年4月10日 星期四 下午 06:44:48 KST  
**地点**: 韩国

以下是根据最终架构设计和实施优先级，列出的需要建立的基础设施资源名称及其详细的核心职责说明。

## 阶段 0/1: 核心基础与任务入口 (必需 - Required)

这些是启动项目、能够接收请求并开始一个（骨架）任务流程所必需的最基础资源。

### Workers

- **api-gateway-worker** (必需)  
  **职责**:  
  - API 统一入口；处理路由。  
  - 执行入口处统一认证 (调用 `shared-libs/auth.ts` 实现 JWT/HMAC 验证)。  
  - 初始化 TraceID (调用 `shared-libs/trace.ts` 生成或提取)。  
  - 执行速率限制。  
  - 记录入口请求/响应日志 (使用 `shared-libs/logger.ts`)。

- **config-api-worker** (必需)  
  **职责**:  
  - 处理用户下载配置相关的 CRUD API 请求。  
  - 必须使用 `logger.ts` 并处理 `traceId` (调用 `trace.ts` 提取)。

- **config-worker** (必需)  
  **职责**:  
  - 根据配置调度后台任务。  
  - 初始化 Task Coordinator DO 状态。  
  - 推送任务到起始队列 (`ImageDownloadQueue`)。  
  - 必须使用 `logger.ts` 并生成/处理 `traceId` (调用 `trace.ts`)。

### Queues (+DLQs)

- **ImageDownloadQueue / ImageDownloadQueue_DLQ** (必需)  
  **职责**:  
  - 缓冲并传递图片下载任务指令，连接 `Config Worker` 到 `Download Worker`。

- **MetadataProcessingQueue / MetadataProcessingQueue_DLQ** (必需)  
  **职责**:  
  - 缓冲并传递元数据提取任务指令，连接 `Download Worker` 到 `Metadata Worker`。

- **AIProcessingQueue / AIProcessingQueue_DLQ** (必需)  
  **职责**:  
  - 缓冲并传递 AI 分析任务指令，连接 `Metadata Worker` 到 `AI Worker`。

### Durable Objects (Binding)

- **TASK_COORDINATOR_DO_BINDING** (必需)  
  **职责**:  
  - (指向 Task Coordinator DO 类) 提供单个任务跨异步步骤的强一致状态跟踪和协调 (按 `taskId` 分片实例化)。

### Storage

- **iN_R2_Bucket** (占位符名称) (必需)  
  **职责**:  
  - 存储所有原始图片文件。

- **iN_D1_Database** (占位符名称) (必需)  
  **职责**:  
  - 存储结构化数据（用户信息、图片元数据基础表、AI 结果文本、配置、任务摘要等），提供初始核心表结构。

### Other Services

- **Cloudflare Pages (in-pages)** (必需)  
  **职责**:  
  - 托管和全球分发 frontend 静态应用（初始可为测试页）。

- **Cloudflare Secrets Store** (必需)  
  **职责**:  
  - 集中、安全地存储和管理所有敏感凭证 (相关 Worker 按需访问)。

## 阶段 2: 骨架流程与可观测性 (必需 - Required)

这些资源使得最小化的端到端流程能够运行（即使是模拟数据），并且可以被观察到。

### Workers (部署骨架逻辑)

- **download-worker** (必需)  
  **职责**:  
  - 从 `ImageDownloadQueue` 接收任务。  
  - 下载原始图片并写入 R2（不做图像处理）。  
  - 调用 `shared-libs/task.ts` 更新 DO 状态。  
  - 推送任务到 `MetadataProcessingQueue`。  
  - (可选) 发布事件。  
  - 必须使用 `logger.ts` 并处理 `traceId`。

- **metadata-worker** (必需)  
  **职责**:  
  - 从 `MetadataProcessingQueue` 接收任务。  
  - 读取 R2 原始图片。  
  - 提取元数据并写入 D1（不做复杂处理）。  
  - 调用 `shared-libs/task.ts` 更新 DO 状态。  
  - 推送任务到 `AIProcessingQueue`。  
  - (可选) 发布事件。  
  - 必须使用 `logger.ts` 并处理 `traceId`。

- **ai-worker** (必需)  
  **职责**:  
  - 从 `AIProcessingQueue` 接收任务。  
  - (骨架阶段模拟 AI 调用)。  
  - 结果写入 D1/Vectorize (若已建)。  
  - 调用 `shared-libs/task.ts` 更新 DO 最终状态。  
  - (可选) 发布事件。  
  - 必须使用 `logger.ts` 并处理 `traceId`。

### Other Services

- **Cloudflare Logpush (iN_Logpush_Job_Axiom - 占位符名称)** (必需)  
  **职责**:  
  - 将所有 Workers 产生的结构化 JSON 日志自动、实时地推送到指定的第三方日志平台 (如 Axiom/Logtail/Sentry)。

## 阶段 3: 完整核心功能 (必需 - Required)

这些资源用于实现项目的主要业务逻辑和对外服务能力。

### Workers (部署完整逻辑)

- **user-api-worker** (必需)  
  **职责**:  
  - 处理用户账户相关的 API 请求。  
  - 必须使用 `logger.ts` 并处理 `traceId`。

- **image-query-api-worker** (必需)  
  **职责**:  
  - 处理图片列表、详情、状态查询相关的 API 请求。  
  - 必须使用 `logger.ts` 并处理 `traceId`。

- **image-mutation-api-worker** (必需)  
  **职责**:  
  - 处理图片元数据修改、标记删除（可能异步）相关的 API 请求。  
  - 必须使用 `logger.ts` 并处理 `traceId`。

- **image-search-api-worker** (必需)  
  **职责**:  
  - 处理图片搜索（关键词、向量）相关的 API 请求。  
  - 必须使用 `logger.ts` 并处理 `traceId`。

- **ai-worker** (完成真实逻辑)  
  **职责更新**:  
  - 调用真实 AI 服务 (优先 CF AI)。  
  - 结果写入 D1/Vectorize。

### Storage

- **iN_Vectorize_Index** (占位符名称) (必需)  
  **职责**:  
  - 存储图片向量 (Embeddings)，支持相似性搜索。

### Other Services

- **Cloudflare AI** (推荐集成)  
  **职责**:  
  - (集成在 `ai-worker` 中) 提供内置的 AI 模型推理能力。

## 阶段 4+: 推荐/可选功能与事件驱动 (根据需求决定)

这些资源用于增强用户体验、系统健壮性、提供附加功能或进一步解耦。

### Workers

- **notification-worker** (推荐)  
  **职责**:  
  - 监听事件队列，根据任务完成/失败状态发送用户通知。  
  - 实现幂等性。  
  - 必须使用 `logger.ts` 并处理 `traceId`。

- **tag-indexer-worker** (推荐)  
  **职责**:  
  - 监听事件队列，根据元数据/AI 结果更新 D1 中的搜索索引或标签。  
  - 实现幂等性。  
  - 必须使用 `logger.ts` 并处理 `traceId`。

- **analytics-worker** (可选)  
  **职责**:  
  - 监听事件队列，收集系统运行和用户行为数据用于分析。  
  - 实现幂等性。  
  - 必须使用 `logger.ts` 并处理 `traceId`。

- **image-update-worker** (可选)  
  **职责**:  
  - 执行任务流最终的状态聚合或清理操作。  
  - 必须使用 `logger.ts` 并处理 `traceId`.

* **image-processing-worker** - *当前已取消*

### Queues (+DLQs)

- **ImageEventsQueue / ImageEventsQueue_DLQ** (可选)  
  **职责**:  
  - (用于混合 Pub/Sub) 广播图片处理相关的里程碑事件。

- **TaskLifecycleEventsQueue / TaskLifecycleEventsQueue_DLQ** (可选)  
  **职责**:  
  - (用于混合 Pub/Sub) 广播任务整体完成或失败的事件。

* **ImageProcessingQueue + DLQ** - *当前已取消*

## Development & Management Tools (贯穿所有阶段 - 必需)

- **Terraform (IaC Tool)**  
  **职责**:  
  - 定义和管理以上所有 Cloudflare 基础设施资源。

- **Monorepo (Code Structure)**  
  **职责**:  
  - 组织管理所有项目代码（包括共享库）。

### Shared Libraries (在代码层面实现，非直接部署资源)

- **shared-libs/logger.ts**  
  - 提供日志能力。

- **shared-libs/trace.ts**  
  - 提供追踪ID处理能力。

- **shared-libs/auth.ts**  
  - 提供认证逻辑实现。

- **shared-libs/task.ts** (推荐)  
  - 封装 DO 状态更新逻辑。

- **shared-libs/events/**  
  - 定义事件接口和类型。

这份清单结合了实施优先级和每个资源的具体职责，应该能为基础设施的建立提供清晰的指引。