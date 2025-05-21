# 📖 iN 项目指南 (Project Guidebook - 架构版本 2025年5月21日)
📄 文档名称：project-guidebook-20250521.md
🗓️ 更新时间：2025-05-21
---

## 🚀 1. 项目简介与使命

**项目名称**: iN - Intelligent Image Infrastructure

**使命与愿景**:
iN 项目旨在构建一个现代化的、基于多云 Serverless 架构的智能图像处理与索引系统。它不仅仅是一个功能性的应用，更是一个探索和实践前沿软件工程范式的平台，包括事件驱动架构、分布式状态协调、基础设施即代码、全面的可观测性以及AI辅助开发。
**愿景**：成为一个清晰、可复用、高度自动化的多云 Serverless 架构蓝本，为个人开发者、小型团队或教育目的提供有价值的参考和起点，并优先利用各云服务商的永久免费资源。


**核心目标**:
演示一个功能完整、架构现代、工程实践规范的多云 Serverless 应用，并尽量利用各平台的永久免费资源。


**项目定位 (基于 `README.md`)**:
iN 是一个面向现代软件工程实践的全栈架构范例，通过实际构建智能图像处理平台，系统性演示以下范式落地：
- 多云 Serverless 架构设计（Vercel 前端, Cloudflare 边缘, GCP核心后端）
- 事件驱动机制（Google Cloud Pub/Sub 为核心消息队列）
- Durable Object (Cloudflare DO) 分布式状态管理
- 全链路结构化日志 + Google Cloud Logging & Monitoring 可观测性接入
- 零信任安全 + 密钥隔离管理（GCP Identity Platform + 各平台Secrets）
- 基础设施即代码（IaC） + 自动化 CI/CD 流程（GitHub Actions）

---

## ✨ 2. 核心特性与价值

**核心特性 (基于 `project-overview-*.md`)**:
- **多云协同**: 优雅地结合 Vercel, Cloudflare, 和 GCP 的优势。
- **Serverless 计算**: 主要依赖 CF Workers, GCP Cloud Functions/Run。
- **事件驱动核心**: GCP Pub/Sub 驱动后端流程。
- **精细化状态管理**: Cloudflare Durable Objects (`TaskCoordinatorDO`)。
- **现代化前端体验**: Vercel 平台。
- **强大的用户认证**: GCP Identity Platform (GCIP)。
- **全面的可观测性**: GCP Cloud Logging & Monitoring。
- **基础设施即代码 (IaC)**: Terraform。
- **自动化CI/CD**: GitHub & GitHub Actions。
- **AI辅助开发**: 设计、文档和部分代码生成过程采用AI工具。

**项目价值与预期成果 (基于 `project-overview-*.md`)**:
- 技术实践平台。
- 可复用组件与模式。
- 成本效益（优先免费资源）。
- AI辅助工程探索。
- 文档驱动开发。

---

## 🛠️ 3. 技术栈与架构

### 3.1. 技术栈概览
(与 `README.md` 中的技术栈表格一致，此处不再重复，可链接或引用 `README.md` 或 `architecture-summary-*.md`)
详情请参考：
- `README.md` -> "核心技术栈概览"
- `docs/architecture-summary-20250521.md` -> "核心架构构件"

### 3.2. 核心架构原则
(与 `README.md` 中的架构指导原则一致，此处不再重复，可链接或引用 `README.md`)
详情请参考：
- `README.md` -> "架构指导原则"
- `docs/architecture-summary-20250521.md` -> "架构关键特性"

### 3.3. 基础设施资源
本项目使用的主要基础设施资源分布在 Vercel, Cloudflare 和 GCP。
详情请参考：`docs/infra-resources-detailed-20250521.md`

---

## ⚙️ 4. 工程实践与开发流程

### 4.1. 工程结构设计 (Monorepo)
- **代码仓库**: GitHub - `your-username/in-project` (请替换为实际地址)
- **Monorepo 管理**: pnpm workspaces + Turborepo
- **目录结构**: `apps/`, `packages/`, `infra/`, `tools/`, `docs/`
详情请参考：`docs/engineering-practices-20250521.md` -> "工程结构设计"

### 4.2. 分支策略 (GitHub)
- 主要分支: `main` (生产), `dev` (开发集成)
- 开发流程: `feature/*` -> `dev` -> (可选 `release/*`) -> `main`
- 紧急修复: `hotfix/*` (从 `main` 创建，合并回 `main` 和 `dev`)
详情请参考：`docs/branch-strategy-20250521.md`

### 4.3. CI/CD (GitHub Actions)
- 统一使用 GitHub Actions 进行自动化测试、构建和多平台部署。
- 关键阶段: Lint, Test, Build, Terraform Plan/Apply, Deploy Applications。
详情请参考：`docs/ci-cd-structure-20250521.md`

### 4.4. 开发与远程环境交互工具
- 由于采用远程部署进行开发和调试，本地主要进行编码和单元测试。
- **核心工具**: Vercel CLI, Wrangler CLI, Google Cloud SDK (`gcloud`), Node.js, pnpm, Terraform CLI, Vitest, Git, GitHub CLI (`gh`)。
详情请参考：`docs/engineering-practices-20250521.md` -> "开发与远程环境交互工具"

### 4.5. 编码与风格规范
- **主要语言**: TypeScript
- **代码风格**: ESLint + Prettier
- **通用规则、各平台编码规范、安全与验证规范**
详情请参考：`docs/coding-guidelines-20250521.md`

### 4.6. 测试策略
- **层级化测试**: 单元测试 (Vitest), 组件测试 (前端), 集成测试 (各平台模拟器/本地服务), E2E测试 (Playwright/Cypress)。
- **自动化**: 所有关键测试集成到 GitHub Actions。
详情请参考：`docs/testing-guidelines-20250521.md`

### 4.7. 安全实践
- **身份与访问管理 (IAM)**: GCIP, GCP Service Accounts, Cloudflare IAM。
- **密钥管理**: GitHub Actions Secrets, Vercel Env Vars, CF Secrets, GCP Secret Manager。
- **应用与服务安全**: 输入验证 (Zod), 输出编码, CORS, WAF, Firestore/Datastore 安全规则等。
详情请参考：`docs/secure-practices-20250521.md` (及 `security-checklist-*.md` 作为其一部分)

---

## 🗺️ 5. 项目规划与实施

### 5.1. MVP 实现清单
定义了最小可行产品所需的核心功能点、测试与部署要求，以及成功标准。
详情请参考：`docs/mvp-manifest-20250521.md`

### 5.2. 分阶段实施方案
项目从初始化到 MVP 实现再到后续扩展的阶段性计划。
详情请参考：`docs/phased-implementation-20250521.md`

### 5.3. 当前任务清单
跟踪当前阶段需要完成的具体任务。
详情请参考：`docs/action-checklist-20250521.md`

### 5.4. 未来路线图
MVP 完成后可能的演进方向和功能增强。
详情请参考：`docs/future-roadmap-20250521.md`

---

## 📚 6. 文档与沟通

- **文档驱动**: 本项目强调文档在先或与开发同步，所有重要设计、决策、流程均需文档化。
- **文档库**: 所有文档存储在代码仓库的 `docs/` 目录下，采用 Markdown 格式。
- **版本与更新**: 文档文件名和内容中包含版本日期，便于追溯。架构变更后及时更新相关文档。
- **沟通与协作 (与AI)**: 清晰指令、迭代反馈、依赖更新后的文档。

---

## 🔗 7. 关键资源与链接 (示例)
- **Vercel Dashboard**: [https://vercel.com/dashboard](https://vercel.com/dashboard)
- **Cloudflare Dashboard**: [https://dash.cloudflare.com/](https://dash.cloudflare.com/)
- **Google Cloud Console**: [https://console.cloud.google.com/](https://console.cloud.google.com/)
- **GitHub Repository**: `https://github.com/7893/iN` (你的仓库)
- **Terraform Registry**: [https://registry.terraform.io/](https://registry.terraform.io/)
- **Turborepo Docs**: [https://turborepo.org/docs](https://turborepo.org/docs)
- **pnpm Docs**: [https://pnpm.io/motivation](https://pnpm.io/motivation)

---

本指南旨在为 iN 项目的参与者提供一个全面的入口和参考，帮助理解项目目标、架构设计、开发流程和工程规范。请定期查阅并参与更新。