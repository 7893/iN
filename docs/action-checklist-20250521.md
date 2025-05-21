# 🌟 action-checklist-20250521.md
_当前阶段 iN 项目任务收敛清单 (架构版本 2025年5月21日)_

## ✅ 核心目标：完成 MVP、打通多云端到端主流程、可视化展示

### 📦 架构 & 基础设施 (Cloudflare & GCP & Vercel & GitHub)
- [x] 完成 Terraform 管理 Cloudflare 核心资源（DO, R2, D1, Vectorize, Workers）
- [ ] **新增**: 完成 Terraform 管理 GCP 核心资源（Pub/Sub, GCIP, Cloud Functions/Run, Firestore, GCS (可选), Logging Sinks）
- [x] 实现 Cloudflare Durable Object 状态机（TaskCoordinatorDO）以协调任务状态
- [x] 配置 Cloudflare Workers 的 wrangler.toml 和 secrets 管理脚本
- [ ] **新增**: 配置 GCP 服务账号及权限 (IAM)，并将凭证安全注入 Cloudflare Workers 和 GitHub Actions
- [ ] **新增**: 配置 Vercel 项目，连接到 GitHub 仓库，设置环境变量
- [ ] **新增**: 配置 GitHub Actions 用于 CI/CD (Lint, Test, Build, Deploy to Vercel, CF, GCP)

### ⚙️ 核心任务链 (GCP Pub/Sub驱动, GCP Functions/Run执行, CF DO协调状态)
- [ ] **重构**: API 网关 (Cloudflare Worker) 接收任务后，初始化 `TaskCoordinatorDO` 并发布消息到 GCP Pub/Sub 的初始主题
- [ ] **重构**: 实现 GCP Cloud Function/Run - 下载服务 (`iN-function-D-download`)
    - [ ] 订阅 GCP Pub/Sub 下载主题
    - [ ] 执行下载逻辑，图片存入 Cloudflare R2 或 GCP GCS
    - [ ] 处理完成后回调 `TaskCoordinatorDO` 更新状态，并发布消息到 GCP Pub/Sub 元数据处理主题
- [ ] **重构**: 实现 GCP Cloud Function/Run - 元数据服务 (`iN-function-E-metadata`)
    - [ ] 订阅 GCP Pub/Sub 元数据主题
    - [ ] 从 R2/GCS 读取图片，提取元数据存入 Cloudflare D1 或 GCP Firestore
    - [ ] 处理完成后回调 `TaskCoordinatorDO` 更新状态，并发布消息到 GCP Pub/Sub AI处理主题
- [ ] **重构**: 实现 GCP Cloud Function/Run - AI 服务 (`iN-function-F-ai`)
    - [ ] 订阅 GCP Pub/Sub AI主题
    - [ ] 调用 AI 服务进行分析（可能需配置对外部AI服务或GCP Vertex AI的调用），向量存入 Cloudflare Vectorize 或 GCP Vertex AI Vector Search
    - [ ] 处理完成后回调 `TaskCoordinatorDO` 更新状态
- [ ] 实现 `TaskCoordinatorDO` 完整状态变更与协调逻辑（基于各GCP服务回调）
- [ ] 确保每个阶段 GCP Cloud Function/Run 的幂等性逻辑

### 📡 API 层建设 (Cloudflare Workers)
- [x] 初始化 API Gateway Worker (`iN-worker-A-api-gateway-20250402`)
- [ ] **重构**: 实现任务触发 API (`iN-worker-B-config-api-20250402`)，集成 GCIP 认证，并将任务发布到 GCP Pub/Sub
- [ ] **重构**: 实现任务查询 API (`iN-worker-H-image-query-api-20250402`)，集成 GCIP 认证，从 `TaskCoordinatorDO` 查询任务状态
- [ ] **重构**: 全面集成 GCP Identity Platform (GCIP) 进行用户认证逻辑 (替换原 Firebase Auth 方案)

### 💻 前端整合 (Vercel)
- [ ] 完成 Vercel 项目初始化 (例如 SvelteKit/Next.js)
- [ ] 实现登录界面 (对接 GCP Identity Platform)
- [ ] 完成任务触发 UI（配置界面）
- [ ] 实现结果查询界面（状态列表 / AI 输出）
- [ ] 联调 Cloudflare API 网关，打通端到端流程

### 🔍 可观测性与健壮性 (GCP Logging & Monitoring)
- [ ] **重构**: 配置 Cloudflare Logpush 将日志导出到 GCP (例如通过 Pub/Sub 中转到 Cloud Logging)
- [ ] **重构**: 定义日志字段规范 + traceId (确保在 Vercel, Cloudflare, GCP 服务间传递)
- [ ] **重构**: 实现 GCP Pub/Sub 死信主题 (Dead-Letter Topics) 基础处理与监控 (替换原DLQ逻辑)
- [ ] **新增**: 在 GCP Monitoring 创建基础仪表盘和告警规则

---
文件名：action-checklist-20250521.md (原 action-checklist-20250422.md)
生成时间：20250521 (根据实际更新时间调整)