# iN 项目实施顺序优化

**当前时间**: 2025年4月10日 星期四 下午 06:30:35 KST  
**地点**: 韩国

以下是吸收了最新建议后的优化版项目实施顺序，整合了早期验证、标准化和健壮性设计的关键实践。

## 阶段 0: 环境搭建与基础奠基 (可部分并行)

### 项目结构与工具链 (必需)

- Monorepo 搭建, TypeScript, Linting, Build 工具配置。

### 核心基础设施即代码 (必需)

- Terraform 配置并部署核心资源:  
  - R2 Bucket  
  - D1 DB 初始结构  
  - 核心 Task Queues + DLQs  
  - DO 绑定  
  - 基础 Worker 定义  
  - Secrets Store

### 共享库 - 核心工具 V1 (必需)

- **shared-libs/logger.ts**: 基础结构化 JSON 日志 (输出到 console)。  
- **shared-libs/trace.ts**: 基础 traceId 生成/提取。  
- (推荐) 基础 CI: 简单 CI 流水线 (Lint, Build, 基础 Terraform 验证)。

## 阶段 1: API 入口与任务启动 (串行)

### 基础安全与 API Gateway (必需)

- **shared-libs/auth.ts**: 实现基础 JWT/HMAC 验证逻辑。  
- **api-gateway-worker**:  
  - 实现基础路由。  
  - 集成 `trace.ts` 进行 TraceID 初始化 (如果请求头无)。  
  - 集成 `auth.ts` 进行入口认证。  
  - 集成 `logger.ts` 记录入口日志。

### 任务创建与状态初始化 (必需)

- **config-api-worker** (或测试端点): 提供简单 API 触发测试任务。  
- **config-worker**:  
  - 实现核心逻辑：接收触发 -> 生成 `taskId` & `traceId` -> 调用 Task Coordinator DO 设置初始状态 -> 推送消息到 `ImageDownloadQueue`。  
  - 确保日志记录。  
- **Task Coordinator DO**: 实现基础状态存储。

### 接入最小化前端测试页 (必需)

- 通过 Cloudflare Pages 部署一个极其简单的 HTML 页面（例如，只有一个按钮或表单）。  
- **页面功能**: 调用 API Gateway 暴露的测试任务触发接口。  
- **验证目标**:  
  - 确保 CORS 配置正确。  
  - 验证 API Gateway 的认证（成功/失败）和错误响应符合预期。  
  - 检查 `traceId` 是否能正确生成并（可选地）在响应头中返回。  
  - 初步感受网络延迟。  
  - 确认从前端到 `Config API Worker` 的调用链通畅。

## 阶段 2: 打通核心处理骨架 (串行，模拟实现)

### 规范化状态与追踪 (必需)

- **定义 TaskStatus Enum**: 在共享库 (如 `shared-libs/types.ts`) 中定义任务状态枚举 (如 `PENDING`, `DOWNLOADING`, `DOWNLOADED_RAW`, `EXTRACTING_METADATA`, `METADATA_EXTRACTED`, `ANALYZING_AI`, `COMPLETED`, `FAILED`, `FAILED_DOWNLOAD` 等)。所有状态更新使用此枚举。  
- **统一 TraceID 传递**:  
  - 约定 Worker 间通过 HTTP Header 传递时使用 `x-trace-id`。  
  - Queue Message 中将其作为 payload 字段。  
  - `shared-libs/trace.ts` 提供提取逻辑。  
- **创建 shared-libs/task.ts** (推荐):  
  - 包含 `async function updateTaskState(taskId: string, state: TaskStatus, traceId: string, /* optional extra data */)` 等工具函数。  
  - 封装与 Task Coordinator DO 的交互逻辑，确保状态更新的一致性和日志记录。

### download-worker (骨架)

- 实现消费 `ImageDownloadQueue`。  
- 使用 `trace.ts` 提取 ID，使用 `logger.ts`。  
- 模拟下载存 R2。  
- 调用 `updateTaskState()` 更新 DO 状态 (使用 TaskStatus Enum)。  
- 推送模拟消息到 `MetadataProcessingQueue`。

### metadata-worker (骨架)

- 实现消费 `MetadataProcessingQueue`。  
- 使用 `trace.ts`, `logger.ts`。  
- 模拟元数据提取写 D1。  
- 调用 `updateTaskState()` 更新 DO 状态。  
- 推送模拟消息到 `AIProcessingQueue`。

### ai-worker (骨架)

- 实现消费 `AIProcessingQueue`。  
- 使用 `trace.ts`, `logger.ts`。  
- 模拟 AI 处理写 D1/Vectorize。  
- 调用 `updateTaskState()` 更新 DO 最终状态。

### 配置 Logpush 并验证追踪 (必需)

- 验证日志能发送到平台，并能通过 `traceId` 串联整个骨架流程。

### 里程碑

- 拥有一个可通过前端测试页触发、基础设施由 Terraform 管理、包含核心组件交互骨架、状态和追踪规范化、并通过日志平台可观测的最小化端到端流程。

## 阶段 3: 实现核心业务功能 (可部分并行)

- **完善 download-worker**: 实现真实下载逻辑和错误处理。  
- **完善 metadata-worker**: 实现真实元数据提取。  
- **完善 ai-worker**: 集成真实 AI 服务。  
- **实现并测试幂等性机制** (必需):  
  - 在 `download-worker`, `metadata-worker`, `ai-worker` 等核心任务 Worker 中，在执行写入 R2/D1/Vectorize 或触发下游等副作用操作之前，增加幂等性检查。  
  - **检查方式**: 通常是查询 Task Coordinator DO 的当前状态。例如，`MetadataWorker` 在开始处理前检查 DO 状态是否小于 `METADATA_EXTRACTED`，如果是等于或之后的状态，则说明可能重复，应直接确认消息或跳过处理。  
  - **测试**: 编写测试用例验证在重复收到同一任务消息时，副作用操作不会被执行多次。  
- **实现查询与搜索 API**: 完成 `image-query-api-worker` 和 `image-search-api-worker`。  
- **开发前端**: 构建功能更完整的前端应用。  
- **完善安全机制**: 强化 `auth.ts` 和权限逻辑。

## 阶段 4: 添加推荐与可选功能 (迭代进行)

- **实现事件发布 & 订阅 Worker**:  
  - 添加 Event Queues，修改核心 Worker 发布事件。  
  - 实现 `notification-worker` (推荐), `tag-indexer-worker` (推荐)。  
  - 确保事件订阅 Worker 也实现幂等性。  
- **实现图片处理方案** (如果需要):  
  - 集成外部函数调用或实现 `image-processing-worker` (及可能的 Unbound 配置)。  
- **完善测试**: 编写更全面的单元、集成、E2E 测试。  
- **完善 CI/CD**: 构建完整的自动化流水线。  
- **实现 analytics-worker** 等其他可选组件。  
- **考虑/设计任务过期机制**: 定义任务超时标准（如 30 分钟未完成），预留 `EXPIRED` 状态。

## 阶段 5: 优化与加固 (持续进行)

- 性能调优, 成本优化, 安全加固。  
- **实现任务清理机制**:  
  - 实现定期 Worker (或利用 DO Alarm) 扫描长时间处于中间状态或 `EXPIRED` 状态的任务，进行标记或清理。  
  - 配置 R2 生命周期规则，自动清理过期的或不再需要的图片文件。  
- 负载测试与容量规划。

这些补充建议极大地提升了实施计划的可行性和质量，使得我们能更早地发现问题、更规范地构建系统，并为未来的健壮性和维护性打下了更好的基础。我们会将这些要点融入到各阶段的实施细节中。