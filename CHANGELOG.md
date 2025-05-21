# 更新日志

所有本项目的重要变更将在此文件中记录。

格式基于 [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)，
且本项目遵循 [Semantic Versioning](https://semver.org/spec/v2.0.0.html)。

## [未发布]

---

## [0.1.0-alpha.20250521] - 2025-05-21

### 新增 (Added)
- **多云架构确立**: 正式采纳 "架构版本 2025年5月21日"。
    - 前端托管平台确定为 **Vercel**。
    - 边缘层、API网关、状态协调和部分边缘存储由 **Cloudflare** (Workers, Durable Objects, R2, D1, Vectorize) 承担。
    - 核心后端服务（计算、消息队列、认证、核心数据库、日志监控）迁移至 **Google Cloud Platform (GCP)**，并优先利用其永久免费资源 (Identity Platform, Pub/Sub, Cloud Functions/Run, Firestore/Datastore, Cloud Logging & Monitoring)。
    - 代码托管和 CI/CD 平台统一为 **GitHub** 和 **GitHub Actions**。
- **GCP 服务集成规划**:
    - **GCP Identity Platform (GCIP)**: 用于用户认证。
    - **GCP Pub/Sub**: 作为核心异步消息队列。
    - **GCP Cloud Functions / Cloud Run**: 执行主要的后端处理逻辑。
    - **GCP Firestore (Native Mode) / Datastore**: 作为核心 NoSQL 数据存储。
    - **GCP Cloud Logging & Monitoring**: 用于集中式日志和监控。
- **文档体系**: 根据新架构大规模更新了项目系列设计文档。
- **CI/CD 规划**: 制定了基于 GitHub Actions 的多平台（Vercel, Cloudflare, GCP）部署策略。
- **IaC 规划**: 扩展 Terraform 配置以同时管理 Cloudflare 和 GCP 资源。

### 变更 (Changed)
- **重大架构调整**:
    - 从先前主要基于 Cloudflare 的设想（或 Cloudflare + Firebase 的组合）**彻底转向 Vercel + Cloudflare + GCP 的多云架构**。
    - **核心后端逻辑执行单元**: 部分原计划在 Cloudflare Workers 中执行的较重任务，调整为在 GCP Cloud Functions/Run 中执行，由 Pub/Sub 驱动。
    - **用户认证机制**: 从原计划的 Firebase Authentication (或更早的 HMAC/JWT 方案) **变更为 GCP Identity Platform (GCIP)**。
    - **消息队列机制**: 从原计划的 Cloudflare Queues (或基于 DO 的简化协调方案) **变更为 GCP Pub/Sub**。
    - **日志监控方案**: 从原计划的 Axiom (或 Cloudflare 原生日志) **变更为 GCP Cloud Logging & Monitoring**。
    - **前端实现方式**: 明确前端由 Vercel 托管。
- **代码仓库与 CI/CD 平台**: 从原设想的 GitLab **迁移到 GitHub / GitHub Actions**。

### 移除 (Removed)
- **Firebase (作为独立服务商的直接依赖)**: 原计划由 Firebase 提供的认证和 Firestore 数据库功能，现由 GCP 内部对应的更通用服务 (GCIP, Firestore Native Mode/Datastore) 承担。
- **Axiom (日志服务)**: 不再作为项目推荐的日志聚合与分析平台。
- **Cloudflare Queues (作为核心任务队列)**: 在当前以最大化利用免费资源并获得完整队列功能的前提下，由 GCP Pub/Sub 替代。

### 修复 (Fixed)
- (此阶段主要为架构设计和规划，较少代码层面的修复)

### 安全性 (Security)
- **认证方案变更**: 明确采用 GCIP 作为用户认证核心，相关的安全考量已纳入新架构设计。
- **密钥管理策略**: 强调跨平台（GitHub Actions Secrets, Vercel Environment Variables, Cloudflare Secrets, GCP Secret Manager）的密钥管理。

### 注意事项 (Notes)
- 本版本代表了一次重大的架构设计迭代，重点在于确立多云技术选型、最大化利用永久免费资源，并为后续的 MVP 开发奠定基础。
- 大量的设计文档已根据此新架构进行了更新。
- 接下来的主要工作是基于此架构进行详细的 IaC 编写和应用代码开发。

---

## [0.0.1-alpha] - 2025-04-15 (历史版本参考)
### 新增
- 项目初始化，基于 Cloudflare Pages, Workers, Queues, D1, R2 的初步架构设计。
- 核心处理流程（下载、元数据、AI）的概念验证。
- 基础的 Terraform 配置管理 Cloudflare 资源。
- 初版系列设计文档。