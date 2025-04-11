# iN 项目基础设施资源清单（含功能说明）

## Workers

- **iN-worker-api-gateway**: 统一 API 入口，执行请求路由、认证、traceId 注入和日志记录。
- **iN-worker-user-api**: 处理用户账户的注册、登录、查询等操作。
- **iN-worker-image-query-api**: 提供图片列表、详情和任务状态查询能力。
- **iN-worker-image-mutation-api**: 支持图片的元数据修改和逻辑删除。
- **iN-worker-image-search-api**: 执行关键词与向量相似性搜索。
- **iN-worker-config-api**: 管理用户下载配置和图片源配置。
- **iN-worker-config**: 根据配置调度任务，初始化 DO 状态，推送至下载队列。
- **iN-worker-download**: 下载原始图片写入 R2，并推进到下一处理阶段。
- **iN-worker-metadata**: 提取图片元数据并存储于 D1。
- **iN-worker-ai**: 调用 AI 服务进行图片分析与向量生成。

## Queues

- **iN-queue-imagedownload**: 传递下载图片任务。
- **iN-queue-imagedownload-dlq**: 存储下载任务失败的消息。
- **iN-queue-metadataprocessing**: 传递元数据提取任务。
- **iN-queue-metadataprocessing-dlq**: 存储元数据提取失败的任务消息。
- **iN-queue-aiprocessing**: 传递 AI 分析任务。
- **iN-queue-aiprocessing-dlq**: 存储 AI 分析失败的任务消息。

## Durable Objects

- **iN-do-task-coordinator**: 为每个任务提供状态协调与进度跟踪。

## Storage

- **iN-r2-bucket**: 存储原始图片。
- **iN-d1-database**: 存储用户、配置、图片元数据与 AI 结果。
- **iN-vectorize-index**: 用于向量存储与相似性搜索。

## Other Services

- **iN-pages**: 托管前端页面。
- **iN-logpush-axiom**: 将结构化日志推送到日志平台（如 Axiom）。

## Infra Management

- **Terraform**: 用于 Cloudflare 全部资源的 IaC 管理。
- **Secrets Store**: 管理 Cloudflare Worker 使用的敏感密钥。
- **Monorepo (pnpm + Turborepo)**: 统一管理前端、Worker 与共享代码的 Monorepo 结构。
