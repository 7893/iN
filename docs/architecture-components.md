## 项目组件清单 (V4 - 反映共享库职责)

### 1. Workers (计算执行单元)

#### api-gateway-worker (Worker) - 必需 (Required)
- 职责: API 统一入口；处理路由；执行入口处统一认证 (调用 shared-libs/auth.ts 实现 JWT/HMAC 验证)；初始化 TraceID (调用 shared-libs/trace.ts 生成或提取)；执行速率限制；记录入口请求/响应日志 (使用 shared-libs/logger.ts)。

#### user-api-worker (Worker) - 必需 (Required)
- 职责: 处理用户账户相关的 API 请求；必须使用 logger.ts 并处理 traceId (调用 trace.ts 提取)。

#### image-query-api-worker (Worker) - 必需 (Required)
- 职责: 处理图片列表、详情、状态查询相关的 API 请求；必须使用 logger.ts 并处理 traceId。

#### image-mutation-api-worker (Worker) - 必需 (Required)
- 职责: 处理图片元数据修改、标记删除（可能异步）相关的 API 请求；必须使用 logger.ts 并处理 traceId。

#### image-search-api-worker (Worker) - 必需 (Required)
- 职责: 处理图片搜索（关键词、向量）相关的 API 请求；必须使用 logger.ts 并处理 traceId。

#### config-api-worker (Worker) - 必需 (Required)
- 职责: 处理用户下载配置相关的 CRUD API 请求；必须使用 logger.ts 并处理 traceId。

#### config-worker (Worker) - 必需 (Required)
- 职责: 根据配置调度后台任务；初始化 DO 状态；推送任务到起始队列；必须使用 logger.ts 并生成/处理 traceId (调用 trace.ts)。

#### download-worker (Worker) - 必需 (Required)
- 职责: 从队列接收任务；下载原始图片并写入 R2（不做图像处理）；更新 DO 状态；推送任务到下一队列 (MetadataProcessingQueue)；(可选) 发布事件；必须使用 logger.ts 并处理 traceId (调用 trace.ts 提取)。

#### metadata-worker (Worker) - 必需 (Required)
- 职责: 从队列接收任务；读取 R2 原始图片；提取元数据并写入 D1（不做复杂处理）；更新 DO 状态；推送任务到下一队列 (AIProcessingQueue)；(可选) 发布事件；必须使用 logger.ts 并处理 traceId。

#### ai-worker (Worker) - 必需 (Required)
- 职责: 从队列接收任务；调用 AI 服务 (优先 CF AI)；结果写入 D1/Vectorize；更新 DO 最终状态；(可选) 发布事件；必须使用 logger.ts 并处理 traceId。

#### notification-worker (Worker) - 推荐 (Recommended)
- 职责: 监听事件队列发送用户通知；实现幂等性；必须使用 logger.ts 并处理 traceId。

#### tag-indexer-worker (Worker) - 推荐 (Recommended)
- 职责: 监听事件队列更新搜索索引；实现幂等性；必须使用 logger.ts 并处理 traceId。

#### analytics-worker (Worker) - 可选 (Optional)
- 职责: 监听事件队列收集分析数据；实现幂等性；必须使用 logger.ts 并处理 traceId。

#### image-processing-worker (Worker) - 可选 (Optional)
- 职责: (如果未来需要图片处理且不外包时使用) 执行图片变换处理；可能需 Unbound 模式；必须使用 logger.ts 并处理 traceId。

#### image-update-worker (Worker) - 可选 (Optional)
- 职责: 执行任务流最终的状态聚合或清理操作；必须使用 logger.ts 并处理 traceId。

---

### 2. Shared Libraries (共享库 - 位于 packages/shared-libs 或类似路径)

- `shared-libs/logger.ts` (Shared Library) - 必需 (Required)
  - 职责: 提供标准化的结构化 JSON 日志输出功能，供所有 Worker 统一调用。

- `shared-libs/trace.ts` (Shared Library) - 必需 (Required)
  - 职责: 提供生成和提取全链路追踪 ID 的工具函数，供所有 Worker 和任务发起者使用。

- `shared-libs/auth.ts` (Shared Library) - 必需 (Required)
  - 职责: 提供 JWT 和 HMAC 签名验证的实现逻辑，供 API Gateway 及其他需要认证能力的 Worker 调用。

---

### 3. Queues (消息队列)

- **ImageDownloadQueue (+ DLQ)** - 必需
- **MetadataProcessingQueue (+ DLQ)** - 必需
- **AIProcessingQueue (+ DLQ)** - 必需
- **ImageEventsQueue (+ DLQ)** - 可选
- **TaskLifecycleEventsQueue (+ DLQ)** - 可选

---

### 4. Durable Objects (DO)

- `Task Coordinator DO` (Type) - 必需
  - 职责: 按 taskId 分片实例化，提供单个任务跨异步步骤的强一致状态跟踪和协调。

---

### 5. Storage (存储)

- **R2 Bucket (`iN_R2_Bucket`)** - 必需
- **D1 Database (`iN_D1_Database`)** - 必需
- **Vectorize Index (`iN_Vectorize_Index`)** - 必需

---

### 6. Other Cloudflare Services (其他 CF 服务)

- **Cloudflare Pages** - 必需
- **Cloudflare Logpush** - 必需
- **Cloudflare AI** - 推荐集成

---

### 7. Development & Management Tools (开发与管理工具)

- **Terraform** (IaC 工具) - 必需
- **Monorepo** (项目结构) - 必需
- **Cloudflare Secrets Store** - 必需

---

📌 **说明**：
- 通用能力如日志、追踪、认证由 `shared-libs` 统一提供。
- 所有 Worker 均需使用 logger.ts/trace.ts，确保可观测性一致。
- 幂等性处理和安全机制需在 Worker 内部实现。
