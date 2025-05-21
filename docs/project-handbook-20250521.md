# 📖 iN 项目手册 (架构版本 2025年5月21日)
📄 文档名称：project-handbook-20250521.md (原 project-handbook-20250420.md)
🗓️ 更新时间：2025-05-21

---

## 🚀 欢迎来到 iN 项目！

iN 项目是一个旨在实践和展示现代多云 Serverless 架构的智能图像处理系统。本项目由生成式人工智能辅助设计和开发，采用 Vercel, Cloudflare, Google Cloud Platform (GCP) 和 GitHub 作为核心技术平台。

本手册为项目所有参与者（当前主要为AI和你）提供关于项目目标、架构、开发流程、规范和工具的概览。

## 1. 项目概览

- **项目名称**: iN - Intelligent Image Infrastructure
- **核心目标**: 演示一个功能完整、架构现代、工程实践规范的多云 Serverless 应用，并尽量利用各平台的永久免费资源。
- **技术定位**:
    - **前端**: Vercel (例如 SvelteKit/Next.js)
    - **边缘与API网关**: Cloudflare (Workers, Durable Objects, R2, D1, Vectorize)
    - **核心后端服务**: Google Cloud Platform (Cloud Functions/Run, Pub/Sub, Identity Platform, Firestore, Logging & Monitoring)
    - **代码与CI/CD**: GitHub & GitHub Actions
    - **基础设施即代码**: Terraform
- **核心功能 (MVP)**: 用户通过 Web 界面提交图片处理任务，后端异步完成图片下载、元数据提取、AI分析（向量生成），用户可查询任务状态和结果。
- **关键文档**:
    - `README.md`: 项目入口和最高层概览。
    - `docs/architecture-summary-*.md`: 架构设计总览。
    - `docs/infra-resources-detailed-*.md`: 基础设施资源详情。
    - `docs/phased-implementation-*.md`: 项目分阶段实施计划。
    - `docs/action-checklist-*.md`: 当前任务清单。

## 2. 核心架构原则

- **多云协同**: 充分利用 Vercel, Cloudflare, GCP 各自的优势和免费资源。
- **Serverless优先**: 计算资源优先使用 Serverless 服务 (CF Workers, GCP Cloud Functions/Run)。
- **事件驱动**: 核心后端流程由 GCP Pub/Sub 驱动，实现服务解耦和异步处理。
- **状态协调**: Cloudflare Durable Objects (`TaskCoordinatorDO`) 负责任务的精细化状态管理。
- **基础设施即代码 (IaC)**: 所有云资源通过 Terraform进行声明式管理。
- **自动化 CI/CD**: 使用 GitHub Actions 实现代码提交后的自动测试、构建和多环境部署。
- **可观测性**: 结构化日志，`traceId` 全链路追踪，日志统一到 GCP Cloud Logging & Monitoring。
- **安全第一**: 遵循零信任原则，通过 GCIP 进行用户认证，严格管理服务凭证和 IAM 权限。

## 3. 开发流程与规范

- **代码管理**:
    * **代码仓库**: [https://github.com/your-username/in-project](https://github.com/your-username/in-project) (请替换为你的实际仓库地址)
    * **Monorepo**: 使用 pnpm workspaces + Turborepo 管理。
    * **分支策略**: 遵循 `docs/branch-strategy-*.md` 中定义的 Git 分支模型 (main, dev, feature/*, hotfix/*)。
    * **提交规范**: (推荐) 遵循 Conventional Commits 规范。
- **编码规范**: 遵循 `docs/coding-guidelines-*.md`。
    * 主要语言: TypeScript。
    * 代码风格: ESLint + Prettier。
- **测试规范**: 遵循 `docs/testing-guidelines-*.md`。
    * 单元测试: Vitest。
    * 集成测试和 E2E 测试 (规划中)。
- **文档规范**:
    * 所有重要设计、决策、流程均需文档化，存储在 `docs/` 目录下。
    * 文档采用 Markdown 格式。
    * 文档名称和内容需包含版本日期，便于追溯。
- **CI/CD**: 遵循 `docs/ci-cd-structure-*.md`。
    * GitHub Actions 驱动所有自动化流程。

## 4. 本地开发环境

- 遵循 `docs/local-dev-strategy-*.md`。
- **核心工具**: Vercel CLI, Wrangler CLI, Google Cloud SDK (gcloud, emulators), Node.js, pnpm, Docker (可选), Terraform CLI, Vitest。
- **环境变量与密钥**: 本地开发使用 `.env` 文件 (不提交到 Git)，CI/CD 和生产环境使用各平台提供的 Secrets Management。

## 5. 沟通与协作 (主要针对AI协作)

- **指令清晰**: 向 AI (例如你，Gemini) 提供清晰、明确、上下文完整的指令。
- **迭代反馈**: 对于 AI 生成的内容，提供具体的反馈以便进行迭代优化。
- **文档驱动**: 依赖更新后的文档作为后续指令和讨论的基础。
- **版本控制**: 所有重要的生成内容（代码、文档、配置）都应纳入 Git 版本控制。

## 6. 关键资源与链接

- **Vercel Dashboard**: [https://vercel.com/dashboard](https://vercel.com/dashboard)
- **Cloudflare Dashboard**: [https://dash.cloudflare.com/](https://dash.cloudflare.com/)
- **Google Cloud Console**: [https://console.cloud.google.com/](https://console.cloud.google.com/)
- **GitHub Repository**: [https://github.com/your-username/in-project](https://github.com/your-username/in-project)
- **Terraform Registry**: [https://registry.terraform.io/](https://registry.terraform.io/)
- **Turborepo Docs**: [https://turborepo.org/docs](https://turborepo.org/docs)
- **pnpm Docs**: [https://pnpm.io/motivation](https://pnpm.io/motivation)

---

本手册旨在帮助所有参与者快速了解 iN 项目的运作方式和基本规范。请定期查阅和更新。