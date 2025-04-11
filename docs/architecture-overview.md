# iN 项目架构概要 (V2 - 移除图片处理)

更新时间：2025-04-10  
地点：韩国  

## 1. 项目目标与原则

- **目标：** 构建一个基于 Cloudflare 的、分布式的图片自动化处理系统，专注于自动化获取、元数据提取、AI 分析、存储、展示图片数据，并提供智能化的图片搜索与分类功能。
- **核心原则：** 异步、事件驱动、模块化、可扩展；注重安全性、可观测性、性能与成本优化；全面拥抱 Cloudflare Native 与 IaC。

## 2. 核心技术栈

- **计算：** Cloudflare Workers（Standard / Unbound）
- **队列：** Cloudflare Queues（含 DLQs）
- **协调：** Durable Objects（按 TaskID 分片）
- **存储：** R2（对象），D1（结构化），Vectorize（向量）
- **前端：** Cloudflare Pages
- **日志：** Logpush → Axiom / Logtail / Sentry
- **AI 能力：** Cloudflare AI / 外部服务（可选）
- **开发管理：** Monorepo（pnpm / Turborepo），Terraform，Secrets Store

## 3. 架构风格

- **分层：** 网关层 / API 层 / 数据处理层 / 协调层 / 存储层
- **模块化：** Worker 职责单一，逻辑轻量
- **通信模式（混合式 Pub/Sub）：**  
  - **任务流程（下载 → 元数据 → AI）：** 由 Task Queue 驱动，顺序明确  
  - **状态广播 / 副作用：** Event Queue 发布事件，实现解耦
- **DO：** 作为主状态协调器，提供任务状态一致性

## 4. 关键组件与交互

- **API Gateway：** 统一入口、路由、认证（JWT/HMAC）、TraceID 生成/传递
- **API Workers：** 执行 D1 查询 / 推送任务，轻量逻辑
- **Data Workers：** 下载、元数据提取、AI，按任务顺序消费，更新状态并推送下游任务
- **Task Coordinator DO：** 强一致状态管理器
- **Queues：** ImageDownloadQueue、MetadataProcessingQueue、AIProcessingQueue（Task）；ImageEventsQueue、TaskLifecycleEventsQueue（Event）；全部支持 DLQ
- **事件处理：** notification/tag-indexer/analytics 等 Worker 可订阅事件队列
- **日志输出：** logger.ts 输出结构化日志，trace.ts 提供 traceId
- **配置与任务调度：** config-worker 执行定期/触发任务派发逻辑

## 5. 图片处理策略

- **明确不做处理：** 当前版本不执行任何图像变换（缩放、水印等）
- **仅处理原图：** 所有处理基于从源下载的原始图片
- **未来扩展：** 如需图片变换，可外包或单独扩展 Worker

## 6. 可观测性

- **traceId：** 由 API Gateway 或调度 Worker 生成，贯穿任务
- **日志：** 使用共享 logger 输出结构化日志（含 traceId、taskId、eventType）
- **采集：** Logpush 推送到日志平台，实现 Trace 链路追踪与性能分析

## 7. 安全策略

- **API 安全：** JWT（用户）与 HMAC（可信系统）认证机制
- **密钥管理：** 使用 Cloudflare Secrets Store，由 Terraform 统一管理绑定
- **内部访问安全：** 暂不使用 Zero Trust，依赖 IP 控制、登录系统或 VPN 限制访问

## 8. 测试策略

- **单元测试：** Vitest / Jest
- **集成测试：** 模拟依赖组件（Queue、DO、D1）逻辑测试
- **端到端测试：** Playwright / Cypress 测试核心链路
- **重点测试：** 幂等性、状态流转、错误处理、异步链路

## 9. 成本考量

- **控制策略：**
  - 避免 Unbound Worker
  - 降低 DO 活跃时间
  - 优化处理流程时间
  - 配置 R2 生命周期管理
- **成本重心：** DO、R2、D1、Vectorize；Worker 使用量超出免费额度
- **预期策略：** 支持合理付费，追求高性价比运行模式

## 10. 演进策略

- **阶段性推进：**
  - 起步阶段：搭建核心骨架、串通主流程
  - 中期迭代：添加副作用模块、搜索能力、前端
  - 后期增强：增加图片处理、推荐分析、插件系统等

- **可选扩展方向：**
  - 多租户能力
  - 插件机制完善
  - 权限模型增强
  - CI/CD 与测试体系完善

---

> 本文档对应的架构图与事件驱动架构请见 `components.md` 与 `event-architecture.md`。
