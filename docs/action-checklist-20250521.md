# 🌟 action-checklist-20250521.md (优雅优先版)
_当前阶段 iN 项目任务收敛清单 (架构版本 2025年5月21日 - 优雅优先)_

## ✅ 核心目标：完成 MVP、打通多云端到端主流程（优化跨云交互）、可视化展示

### 📦 架构 & 基础设施 (Cloudflare & GCP & Vercel & GitHub)
- [x] 完成 Terraform 管理 Cloudflare 核心资源（DO, R2, D1, Vectorize, Workers）
- [ ] **新增/强化**: 完成 Terraform 管理 GCP 核心资源（Pub/Sub, GCIP, Cloud Functions/Run, **Firestore (用于详细状态)**, GCS (主要对象存储), Logging Sinks）
- [x] 实现 Cloudflare Durable Object 状态机（`TaskCoordinatorDO`）以协调任务的**最终/摘要状态**
- [x] 配置 Cloudflare Workers 的 wrangler.toml 和 secrets 管理脚本
- [ ] **新增**: 配置 GCP 服务账号及权限 (IAM)，并将凭证安全注入 Cloudflare Workers 和 GitHub Actions
- [ ] **新增**: 配置 Vercel 项目，连接到 GitHub 仓库，设置环境变量
- [ ] **新增**: 配置 GitHub Actions 用于 CI/CD (Lint, Test, Build, Deploy to Vercel, CF, GCP)

### ⚙️ 核心任务链 (GCP Pub/Sub驱动GCP内部流程, GCP Functions/Run执行, GCP Firestore记录详细状态, CF DO记录最终/摘要状态)
- [ ] **重构**: API 网关 (Cloudflare Worker) 接收任务后，初始化 `TaskCoordinatorDO`（记录`taskId`, `submitted`状态），并将包含`taskId`的任务信息发布到 GCP Pub/Sub 的初始主题。
- [ ] **新增**: 设计 GCP Firestore 中用于存储任务详细处理状态和中间结果的数据模型。
- [ ] **重构**: 实现 GCP Cloud Function/Run - 下载服务 (`gcp-func-download-image`)
    - [ ] 订阅 GCP Pub/Sub 下载主题。
    - [ ] 执行下载逻辑，图片**主要存入 GCP GCS**。
    - [ ] 处理完成后，在**GCP Firestore中更新该阶段的详细状态**，并发布消息到 GCP Pub/Sub 元数据处理主题。
    - [ ] **(仅在GCP流程最终完成或关键节点)** 通过专门的GCP Function/Run回调 `TaskCoordinatorDO` 更新其最终/摘要状态。
- [ ] **重构**: 实现 GCP Cloud Function/Run - 元数据服务 (`gcp-func-metadata-extract`)
    - [ ] 订阅 GCP Pub/Sub 元数据主题。
    - [ ] 从 GCS 读取图片，提取元数据存入 GCP Firestore (或 Cloudflare D1 如果有特定边缘需求)。
    - [ ] 处理完成后，在**GCP Firestore中更新该阶段的详细状态**，并发布消息到 GCP Pub/Sub AI处理主题。
    - [ ] **(同上)** 低频回调 `TaskCoordinatorDO`。
- [ ] **重构**: 实现 GCP Cloud Function/Run - AI 服务 (`gcp-func-ai-analyze` 或 `gcp-service-ai-processor`)
    - [ ] 订阅 GCP Pub/Sub AI主题。
    - [ ] 调用 AI 服务进行分析，向量存入 Cloudflare Vectorize 或 GCP Vertex AI Vector Search。
    - [ ] 处理完成后，在**GCP Firestore中更新该阶段的详细状态**。
    - [ ] **(同上)** 这是GCP内部流程的最后一步，**必须回调 `TaskCoordinatorDO`** 更新任务的最终完成或失败状态。
- [ ] **调整**: 实现 `TaskCoordinatorDO` 逻辑，使其主要处理来自GCP流程的**最终/摘要状态更新回调**。
- [ ] 确保每个阶段 GCP Cloud Function/Run 的幂等性逻辑，以及更新GCP Firestore状态的原子性/一致性。

### 📡 API 层建设 (Cloudflare Workers)
- [x] 初始化 API Gateway Worker (`cf-worker-api-gateway`)
- [ ] **重构**: 实现任务触发 API (在API Gateway或`cf-worker-config-api`中)，集成 GCIP 认证，初始化DO，并将任务发布到 GCP Pub/Sub。
- [ ] **重构**: 实现任务查询 API (在API Gateway或`cf-worker-image-query-api`中)，集成 GCIP 认证，主要从 `TaskCoordinatorDO` 查询任务的**最终/摘要状态**。 (可选：如需详细进度，则考虑从GCP Firestore查询的机制)。
- [ ] **重构**: 全面集成 GCP Identity Platform (GCIP) 进行用户认证逻辑。

### 💻 前端整合 (Vercel)
- [ ] 完成 Vercel 项目初始化 (例如 SvelteKit/Next.js)。
- [ ] 实现登录界面 (对接 GCP Identity Platform)。
- [ ] 完成任务触发 UI（配置界面）。
- [ ] 实现结果查询界面（状态列表 / AI 输出，主要基于DO的摘要状态）。
- [ ] 联调 Cloudflare API 网关，打通端到端流程。

### 🔍 可观测性与健壮性 (GCP Logging & Monitoring)
- [ ] **重构**: 配置 Cloudflare Logpush 将日志导出到 GCP (例如通过 Pub/Sub 中转到 Cloud Logging)。
- [ ] **重构**: 定义日志字段规范 + traceId (确保在 Vercel, Cloudflare, GCP 服务间传递)。
- [ ] **重构**: 实现 GCP Pub/Sub 死信主题 (Dead-Letter Topics) 基础处理与监控。
- [ ] **新增**: 在 GCP Monitoring 创建基础仪表盘和告警规则（监控GCP内部流程和Pub/Sub）。

---
文件名：action-checklist-20250521.md (原 action-checklist-20250422.md)
更新日期: 2025年5月21日 23:01 (CST)