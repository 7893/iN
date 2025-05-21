# 🪜 分阶段实施方案 (架构版本 2025年5月21日)
📄 文档名称：phased-implementation-20250521.md (原 phased-implementation-20250422.md)
🗓️ 更新时间：2025-05-21

---

本项目 iN 采用分阶段实施策略，确保每个阶段都有明确的可交付成果和验证点。当前架构基于 Vercel, Cloudflare, Google Cloud Platform (GCP) 和 GitHub。

## 阶段 0：项目初始化与核心架构定义 (已完成或正在收尾)

- **目标**: 建立项目基础，明确技术选型和核心架构。
- **产出**:
    - ✅ **GitHub 仓库** 初始化，采用 Monorepo (pnpm + Turborepo) 结构。
    - ✅ **Vercel 项目** 初始化，并与 GitHub 仓库连接。
    - ✅ **Cloudflare 账户** 准备就绪。
    - ✅ **GCP 项目** 创建并启用所需 API (Identity Platform, Pub/Sub, Cloud Functions, Cloud Run, Firestore, Logging, Monitoring, Secret Manager等)。
    - ✅ **核心技术选型敲定**: Vercel (前端), Cloudflare (边缘/API/DO/边缘存储), GCP (核心后端/消息/认证/日志), GitHub (代码/CI/CD)。
    - ✅ **核心架构文档** 初稿完成并根据新架构进行更新 (如 `README.md`, `architecture-summary-*.md`, `infra-resources-detailed-*.md` 等)。
    - ✅ **Terraform 基础配置**: 初始化 Cloudflare 和 GCP Provider，定义基础网络和项目设置（如果适用）。
    - ✅ **GitHub Actions 基础CI流程**: 建立基本的 Lint, Test, Build 流程。

## 阶段 1：基础设施即代码 (IaC) 与认证核心搭建 (Terraform & GCP Identity Platform)

- **目标**: 使用 Terraform 搭建 Cloudflare 和 GCP 的核心基础设施，并完成用户认证模块。
- **产出**:
    - **Cloudflare 资源 (Terraform)**:
        - API Gateway Worker (骨架)。
        - `TaskCoordinatorDO` (骨架及绑定)。
        - R2 Bucket, D1 Database, Vectorize Index (基础定义)。
        - Logpush 配置 (指向 GCP 的初步设置)。
    - **GCP 资源 (Terraform)**:
        - Pub/Sub 主题和订阅 (核心任务链所需)。
        - Pub/Sub 死信主题 (DLT) 结构。
        - Cloud Functions/Run 服务定义 (骨架)。
        - Firestore (Native Mode) / Datastore 实例和基础安全规则。
        - GCS Bucket (可选，用于图片存储或日志归档)。
        - GCP Identity Platform (GCIP) 用户池配置，启用 Google/GitHub 等 OAuth 提供商。
        - 服务账号 (Service Accounts) 和 IAM 权限配置。
        - Secret Manager 中存储必要的密钥。
    - **Vercel 前端**:
        * 实现登录/注册页面，集成 GCIP 客户端 SDK，完成用户登录和 ID Token 获取。
    - **Cloudflare API Gateway Worker**:
        * 实现 `/auth/verify` (或其他类似) 端点，用于验证 GCIP ID Token。
    - **文档**: 更新 `infra-resources-detailed-*.md`, `secure-practices-*.md`。

## 阶段 2：核心任务处理链路 MVP (GCP Pub/Sub + Functions/Run + Cloudflare DO)

- **目标**: 打通从任务提交到核心处理（下载、元数据、AI）的异步流程，并实现状态的协调与持久化。
- **产出**:
    - **Cloudflare API Gateway Worker**:
        * 实现任务提交API (`/api/tasks`)，接收前端请求，校验（包括Token），初始化 `TaskCoordinatorDO`，并将任务消息发布到 GCP Pub/Sub 的第一个主题。
    - **GCP Cloud Functions / Cloud Run**:
        * **下载服务**: 订阅 Pub/Sub 下载主题，下载图片存入 R2/GCS，处理完成后向 Pub/Sub 下一阶段主题发消息，并回调 DO 更新状态。
        * **元数据提取服务**: 订阅 Pub/Sub 元数据主题，从 R2/GCS 读取图片，提取元数据存入 D1/Firestore，处理完成后向 Pub/Sub 下一阶段主题发消息，并回调 DO 更新状态。
        * **AI 分析服务**: 订阅 Pub/Sub AI 主题，进行 AI 分析（可先用 mock AI 服务），向量存入 Vectorize/Vertex AI，处理完成后回调 DO 更新状态。
    - **Cloudflare Durable Object (`TaskCoordinatorDO`)**:
        * 实现完整的状态机逻辑，处理来自 GCP Functions/Run 的状态回调，管理任务从创建到完成/失败的整个生命周期。
        * 提供任务状态查询接口，供 API Gateway Worker 调用。
    - **Vercel 前端**:
        * 实现任务配置表单，用户可以提交新的图像处理任务。
        * 实现任务状态查询界面，可以轮询或通过其他方式（MVP阶段可简化）获取并展示任务状态。
    - **共享库 (`packages/shared-libs`)**:
        * 完善事件定义 (`INEvent<T>`) 和各阶段的 Payload 类型。
        * 完善日志和追踪工具函数。
    - **测试**: 单元测试覆盖核心逻辑，集成测试打通 Pub/Sub 消息传递和 DO 回调。

## 阶段 3：可观测性、错误处理与前端体验优化

- **目标**: 建立基础的日志监控和告警体系，完善错误处理，优化前端用户体验。
- **产出**:
    - **日志与监控 (GCP Logging & Monitoring)**:
        * 确保所有服务（Vercel, CF Workers/DO, GCP Functions/Run）的结构化日志都能正确推送到 GCP Cloud Logging。
        * 在 GCP Monitoring 中创建基础仪表盘，监控 API 流量、Pub/Sub 消息队列长度、Function/Run 执行情况、DO 状态等。
        * 配置 GCP Pub/Sub 死信主题 (DLT) 并实现基本的日志记录和告警。
    - **错误处理**:
        * 完善各服务（特别是 GCP Functions/Run 和 DO）的错误捕获、记录和向用户/管理员的反馈机制。
    - **Vercel 前端**:
        * 优化任务配置和状态展示页面的用户体验。
        * 实现更友好的加载状态和错误提示。
    - **CI/CD 完善 (GitHub Actions)**:
        * 实现将应用和服务自动部署到开发/预览 (dev) 和生产 (main) 环境。
        * 将 Terraform Plan/Apply 集成到 GitHub Actions。

## 阶段 4：功能扩展与优化 (MVP 后)

- **目标**: 根据 `future-roadmap-*.md` 中的规划，逐步实现更多高级功能和系统优化。
- **产出 (示例)**:
    * 向量搜索功能的前后端完整实现。
    * 实时/准实时任务状态更新。
    * 更细致的 DLT 消息处理和自动化重试机制。
    * 更多旁路事件订阅者 (如通知服务)。
    * 部署策略优化 (如 Canary/蓝绿部署)。
    * 成本监控与优化。
    * 安全性加固和审计。

---
此分阶段实施方案为 iN 项目的开发提供了清晰的路径和里程碑，确保项目在多云环境下能够稳步推进，并持续交付价值。