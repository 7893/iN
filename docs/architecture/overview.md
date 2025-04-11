# iN 项目架构概要 (V2 - 移除图片处理)

## 1. 项目目标与原则

- **目标**: 构建一个基于 Cloudflare 的、分布式的图片自动化处理系统，专注于自动化获取、元数据提取、AI分析、存储、展示图片数据，并提供智能化的图片搜索与分类功能。
- **核心原则**: 采用异步、事件驱动、模块化、可扩展的设计；注重安全性、高可观测性、性能与成本优化；全面拥抱 Cloudflare Native 服务与基础设施即代码 (IaC)。

## 2. 核心技术栈

- **计算**: Cloudflare Workers (Standard / Unbound 备用)
- **消息队列**: Cloudflare Queues (+ DLQs)
- **状态协调**: Durable Objects (按 TaskID 分片)
- **存储**: Cloudflare R2 (对象), Cloudflare D1 (结构化数据), Cloudflare Vectorize (向量)
- **前端部署**: Cloudflare Pages
- **日志**: Cloudflare Logpush -> Axiom / Logtail / Sentry 等
- **AI 能力**: Cloudflare AI (优先) 或谨慎集成外部 AI

## 3. 开发与管理

- **代码管理**: Monorepo (pnpm / Turborepo)
- **基础设施**: Terraform (统一管理所有 CF 资源)
- **密钥管理**: Cloudflare Secrets Store

## 4. 架构风格

- **分层**: 网关层 / API 层 / 数据处理层 / 协调层 / 存储层。
- **模块化**: Worker 职责单一、逻辑轻量化。
- **通信模式 (混合式 Pub/Sub)**:
    - 核心业务流程 (下载 -> 元数据 -> AI): 由任务队列 (Task Queues) 驱动，顺序明确。
    - 状态广播/副作用: 通过事件队列 (Event Queues) 发布标准化事件 (统一结构与命名)，实现解耦。

## 5. 关键组件与交互

- **API Gateway**: 统一入口，路由, 认证 (JWT/HMAC), Trace ID 生成/传递。
- **API Workers**: 处理特定 API 请求，轻量化，操作 D1 或推送任务/事件到队列。
- **Data Workers (Download, Metadata, AI 等)**: 处理后台任务，由队列触发，执行单一、优化的步骤，更新 DO 状态，发布事件/推送到下游队列。
- **Download Worker**: 仅下载图片写入 R2，更新 DO 状态，推送任务到 MetadataProcessingQueue。
- **Metadata Worker**: 由 MetadataProcessingQueue 触发，从 R2 读取原始图片，提取元数据写入 D1，推送任务到 AIProcessingQueue。
- **AI Worker**: 由 AIProcessingQueue 触发，执行 AI 分析，结果写入 D1/Vectorize，更新 DO 最终状态。
- **Config Worker**: 任务调度与配置管理，初始化 DO，推送任务到起始队列。
- **Task Coordinator DO**: 按 TaskID 分片，提供核心任务链的强一致状态管理。
- **Queues**: Task Queues (ImageDownloadQueue, MetadataProcessingQueue, AIProcessingQueue) + Event Queues (如 ImageEventsQueue, TaskLifecycleEventsQueue)。均配置 DLQ。
- **Plugins**: 预留图片源、存储、AI 处理的插件扩展点。

## 6. 图片处理策略

- **明确不做处理**: 当前设计不包含对图片进行变换处理（如缩放、水印、格式转换）的功能。
- **处理原始图片**: 系统将直接处理和存储从源获取的原始图片。后续的元数据提取、AI 分析均基于原始图片进行。
- **未来扩展**: 如果未来需要图片处理功能，可以再考虑引入外部服务或专用 Worker。

## 7. 可观测性

- **追踪**: traceId 贯穿所有请求、队列消息、日志。
- **日志**: 使用共享库输出结构化 JSON 日志 (含 traceId, eventType, taskId 等)，通过 Logpush 集中收集。
- **分析**: 在日志平台 (Axiom/Logtail/Sentry等) 利用 traceId 进行全链路追踪、性能瓶颈分析、错误排查和告警。

## 8. 安全性

- **API 认证**: JWT (用户), HMAC (可信系统)。
- **密钥管理**: Secrets Store。
- **内部资源安全**: 暂不使用 Cloudflare Access/Zero Trust，需依赖 IP 限制、应用层登录、VPN 等其他方法保护非公开资源。

## 9. 测试策略

- 全面的自动化测试：单元测试、集成测试 (Vitest/Jest)、端到端测试 (Playwright/Cypress)。

## 10. 成本考量

- **优化重点**: 最小化 Worker CPU 执行时间，避免/谨慎使用 Unbound 模式，缩短任务时长以降低 DO 成本。
- **主要成本来源**: Durable Objects (因其定价模型和低免费额度)，以及业务量增长后可能超出免费额度的 Workers/Queues/R2/D1/Vectorize 用量。
- **成本降低**: 通过取消图片变换处理步骤，避免了相关的潜在成本（如外部服务费或 Workers Unbound 费用）。
- **策略**: 接受付费，目标是高性价比而非完全免费，需持续监控与优化成本。

## 11. 演进策略

- 模块化设计支持从当前核心功能开始，按需逐步迭代，未来可按需添加图片处理、更复杂的事件订阅者、完善 CI/CD 等。