好的，我们根据刚才讨论的将通用能力（日志、追踪、认证逻辑）提取到 `shared-libs` 的方案，来重新梳理这份资源组件清单及其职责描述。

*(当前时间: 2025年4月10日 星期四 下午 06:23:07 KST, 地点: 韩国)*

---

**iN 项目资源组件清单 (V4 - 反映共享库职责)**

**1. Workers (计算执行单元)**

* `api-gateway-worker` (Worker) - **必需 (Required)**
    * **职责:** API 统一入口；处理路由；执行**入口处**统一认证 (调用 `shared-libs/auth.ts` 实现 JWT/HMAC 验证)；**初始化 TraceID** (调用 `shared-libs/trace.ts` 生成或提取)；执行速率限制；记录入口请求/响应日志 (使用 `shared-libs/logger.ts`)。
* `user-api-worker` (Worker) - **必需 (Required)**
    * **职责:** 处理用户账户相关的 API 请求；**必须使用 `logger.ts` 并处理 `traceId`** (调用 `trace.ts` 提取)。
* `image-query-api-worker` (Worker) - **必需 (Required)**
    * **职责:** 处理图片列表、详情、状态查询相关的 API 请求；**必须使用 `logger.ts` 并处理 `traceId`**。
* `image-mutation-api-worker` (Worker) - **必需 (Required)**
    * **职责:** 处理图片元数据修改、标记删除（可能异步）相关的 API 请求；**必须使用 `logger.ts` 并处理 `traceId`**。
* `image-search-api-worker` (Worker) - **必需 (Required)**
    * **职责:** 处理图片搜索（关键词、向量）相关的 API 请求；**必须使用 `logger.ts` 并处理 `traceId`**。
* `config-api-worker` (Worker) - **必需 (Required)**
    * **职责:** 处理用户下载配置相关的 CRUD API 请求；**必须使用 `logger.ts` 并处理 `traceId`**。
* `config-worker` (Worker) - **必需 (Required)**
    * **职责:** 根据配置调度后台任务；初始化 DO 状态；推送任务到起始队列；**必须使用 `logger.ts` 并生成/处理 `traceId`** (调用 `trace.ts`)。
* `download-worker` (Worker) - **必需 (Required)**
    * **职责:** 从队列接收任务；下载原始图片并写入 R2（不做图像处理）；更新 DO 状态；推送任务到下一队列 (`MetadataProcessingQueue`)；(可选) 发布事件；**必须使用 `logger.ts` 并处理 `traceId`** (调用 `trace.ts` 提取)。
* `metadata-worker` (Worker) - **必需 (Required)**
    * **职责:** 从队列接收任务；读取 R2 原始图片；提取元数据并写入 D1（不做复杂处理）；更新 DO 状态；推送任务到下一队列 (`AIProcessingQueue`)；(可选) 发布事件；**必须使用 `logger.ts` 并处理 `traceId`**。
* `ai-worker` (Worker) - **必需 (Required)**
    * **职责:** 从队列接收任务；调用 AI 服务 (优先 CF AI)；结果写入 D1/Vectorize；更新 DO 最终状态；(可选) 发布事件；**必须使用 `logger.ts` 并处理 `traceId`**。
* `notification-worker` (Worker) - **推荐 (Recommended)**
    * **职责:** 监听事件队列发送用户通知；实现幂等性；**必须使用 `logger.ts` 并处理 `traceId`**。
* `tag-indexer-worker` (Worker) - **推荐 (Recommended)**
    * **职责:** 监听事件队列更新搜索索引；实现幂等性；**必须使用 `logger.ts` 并处理 `traceId`**。
* `analytics-worker` (Worker) - **可选 (Optional)**
    * **职责:** 监听事件队列收集分析数据；实现幂等性；**必须使用 `logger.ts` 并处理 `traceId`**。
* `image-processing-worker` (Worker) - **可选 (Optional)**
    * **职责:** (如果未来需要图片处理且不外包时使用) 执行图片变换处理；可能需 Unbound 模式；**必须使用 `logger.ts` 并处理 `traceId`**。
* `image-update-worker` (Worker) - **可选 (Optional)**
    * **职责:** 执行任务流最终的状态聚合或清理操作；**必须使用 `logger.ts` 并处理 `traceId`**。

**2. Shared Libraries (共享库 - 位于 Monorepo 的 `packages/shared-libs` 或类似路径)**

* `shared-libs/logger.ts` (Shared Library) - **必需 (Required)**
    * **职责:** 提供标准化的**结构化 JSON 日志**输出功能（包含 `timestamp`, `traceId`, `workerName`, `level`, `message`, `extra data` 等），供所有 Worker 统一调用。
* `shared-libs/trace.ts` (Shared Library) - **必需 (Required)**
    * **职责:** 提供**生成**和**提取**全链路追踪 ID (`traceId`) 的工具函数，供所有 Worker 和任务发起者使用。
* `shared-libs/auth.ts` (Shared Library) - **必需 (Required)**
    * **职责:** 提供 **JWT** 和 **HMAC** 签名**验证**的实现逻辑，供 API Gateway 及其他需要认证能力的 Worker 调用。

**3. Queues (消息队列)**

* `ImageDownloadQueue` (+ DLQ) (Queue) - **必需 (Required)**
    * **职责:** 缓冲并传递图片下载任务指令。
* `MetadataProcessingQueue` (+ DLQ) (Queue) - **必需 (Required)**
    * **职责:** 缓冲并传递元数据提取任务指令。
* `AIProcessingQueue` (+ DLQ) (Queue) - **必需 (Required)**
    * **职责:** 缓冲并传递 AI 分析任务指令。
* `ImageEventsQueue` (+ DLQ) (Queue) - **可选 (Optional)**
    * **职责:** (用于混合 Pub/Sub) 广播图片处理相关的里程碑事件。
* `TaskLifecycleEventsQueue` (+ DLQ) (Queue) - **可选 (Optional)**
    * **职责:** (用于混合 Pub/Sub) 广播任务整体完成或失败的事件。

**4. Durable Objects (DO)**

* `Task Coordinator DO` (Type) (Durable Object) - **必需 (Required)**
    * **职责:** (按 `taskId` 分片实例化) 提供单个任务跨异步步骤的强一致状态跟踪和协调。

**5. Storage (存储)**

* `iN_R2_Bucket` (*占位符名称*) (R2 Bucket) - **必需 (Required)**
    * **职责:** 存储原始图片文件。
* `iN_D1_Database` (*占位符名称*) (D1 Database) - **必需 (Required)**
    * **职责:** 存储结构化数据（用户信息、图片元数据、AI 结果文本、配置、任务摘要等）。
* `iN_Vectorize_Index` (*占位符名称*) (Vectorize Index) - **必需 (Required)**
    * **职责:** 存储图片向量 (Embeddings)，支持相似性搜索。

**6. Other Cloudflare Services (其他 CF 服务)**

* Cloudflare Pages (CF Service) - **必需 (Required)**
    * **职责:** 托管和全球分发 `frontend` 静态应用。
* Cloudflare Logpush (CF Service) - **必需 (Required)**
    * **职责:** 将 Workers 产生的结构化日志自动推送到指定的第三方日志平台。
* Cloudflare AI (CF Service) - **推荐集成 (Recommended Integration)**
    * **职责:** (集成在 `ai-worker` 中) 提供内置的 AI 模型推理能力。

**7. Development & Management Tools (开发与管理工具)**

* Terraform (IaC Tool) - **必需 (Required)**
    * **职责:** 定义和管理所有 Cloudflare 资源。
* Monorepo (Code Structure) - **必需 (Required)**
    * **职责:** 组织管理所有项目代码（包括 `shared-libs`）。
* Cloudflare Secrets Store (CF Service / Management Feature) - **必需 (Required)**
    * **职责:** 集中、安全地存储和管理所有敏感凭证 (相关 Worker 通过绑定按需访问)。

---

**注记:**

* **通用能力实现:** 日志记录、追踪 ID 处理、认证逻辑的**具体实现**位于 `shared-libs` 中。
* **Worker 责任:** 所有 Worker **都有责任**在处理请求或消息时，调用 `shared-libs` 中的工具来正确处理日志记录和追踪 ID。
* **未来考虑:** 多租户支持、详细 Secrets 映射等需在后续设计中明确。

---

这份清单现在更准确地反映了通用能力通过共享库实现，而各个 Worker 负责调用这些库来履行相应职责的架构模式。