# 🧠 iN 工程实践说明 (架构版本 2025年5月21日)
📄 文档名称：engineering-practices-20250521.md
🗓️ 更新时间：2025-05-21

---

## ✅ 工程结构设计 (Monorepo)

- **代码库**: 使用 **GitHub** 作为唯一的代码托管平台。
- **Monorepo 管理**:
    - 使用 **pnpm workspaces** + **Turborepo** 实现 Monorepo 管理，集中管理前端 (Vercel 项目)、Cloudflare 应用 (Workers, DO)、GCP 应用 (Cloud Functions/Run)、共享库、IaC (Terraform)、工具脚本等。
    - 目录结构: `apps/` (各独立部署单元), `packages/` (共享库), `infra/` (Terraform代码), `tools/` (辅助脚本), `docs/` (项目文档)。
- **职责分离**:
    - `apps/` 内的每个应用（例如 Vercel 前端项目, Cloudflare API Gateway Worker, `TaskCoordinatorDO`, GCP Download Function 等）应有明确的单一职责。
    * `packages/` 内的共享库（如 `shared-libs`）封装通用逻辑、类型定义、工具函数，供各应用复用。
- **配置统一与分离**:
    - Cloudflare Workers/DO 配置通过各自的 `wrangler.toml` 管理。
    * GCP Cloud Functions/Run 服务定义和配置 (部分通过 `gcloud` CLI 参数，部分通过 Terraform)。
    * Vercel 项目配置通过 Vercel UI 或 `vercel.json`。
    * Terraform (`infra/`) 统一管理 Cloudflare 和 GCP 的核心基础设施资源。

---

## 🧪 开发与测试流程

- **本地开发环境**:
    - **Vercel**: 使用 `vercel dev` 运行和调试前端应用。
    - **Cloudflare**: 使用 `wrangler dev` 运行和测试 Cloudflare Workers 和 Durable Objects，可配置本地模拟或连接到测试环境的 GCP 服务。
    - **GCP**: 使用 Google Cloud SDK 和相关模拟器 (如 Pub/Sub emulator, Functions Framework) 在本地开发和测试 Cloud Functions/Run。
    - **共享库**: 在 `packages/` 中开发，通过 pnpm workspaces 链接到各应用。
- **单元测试**:
    - 使用 **Vitest** 作为主要的单元测试框架，覆盖所有共享库和应用中的关键业务逻辑、纯函数等。
    * 测试应与代码存放在一起 (例如 `*.test.ts` 文件)。
- **集成测试**:
    - **Cloudflare**: `wrangler dev` 配合 Postman/curl 或自动化脚本测试 API Gateway Worker 与 `TaskCoordinatorDO` 的交互，以及 DO 与（模拟的或真实的测试环境）GCP 服务回调的流程。
    - **GCP**: 测试 Cloud Functions/Run 对 Pub/Sub 消息的正确处理，以及与 Firestore, GCS, `TaskCoordinatorDO` 回调等服务的集成。
    - (可选) **端到端 (E2E) 测试**: 使用 Playwright 或 Cypress 从 Vercel 前端发起操作，验证整个链路（Vercel -> CF API GW -> DO -> Pub/Sub -> GCP Function/Run -> DO 回调 -> 数据存储 -> 前端状态更新）的正确性。
- **CI/CD 流程 (GitHub Actions)**:
    * **触发**: PR 到 `dev`/`main` 或直接 push 到 `dev`/`main`。
    * **阶段**:
        1.  Lint & Format (ESLint, Prettier)。
        2.  Unit Tests (Vitest, `pnpm turbo test`)。
        3.  Build (Turborepo, `pnpm turbo build`)。
        4.  (PR specific) Terraform Plan (生成并评论计划)。
        5.  (Merge to dev/main) Terraform Apply (应用到对应Staging/Prod环境)。
        6.  (Merge to dev/main) Deploy Applications (Vercel CLI, Wrangler CLI, gcloud CLI) 到对应Staging/Prod环境。
    * 详细定义见 `ci-cd-structure-*.md`。

---

## 🛡️ 安全与认证实践

- **用户级认证**:
    * 使用 **Google Cloud Identity Platform (GCIP)** 实现用户注册、登录 (支持 OAuth: Google/GitHub 等) 和身份管理。
    * Vercel 前端负责与 GCIP SDK 交互获取 ID Token。
    * Cloudflare API Gateway Worker 负责验证 GCIP ID Token。
- **服务级认证/授权**:
    * **Cloudflare Workers -> GCP Services**: 使用 GCP 服务账号 (Service Account) JSON 密钥，通过 Cloudflare Secrets 注入，Worker 使用此凭证安全调用 GCP API (如 Pub/Sub, Firestore)。遵循最小权限原则。
    * **GCP Services (Internal)**: GCP 服务间默认使用其附加的服务账号权限。
    * **Cloudflare Workers/DO (Internal)**: Worker 与 DO 间，或 Worker 与 Worker 间的调用，如需额外安全，可考虑使用 Cloudflare Access Authenticated Origin Pulls 或自定义签名机制 (如 HMAC)。
- **配置与密钥管理**:
    * 所有密钥、API Token、服务账号凭证等敏感信息，**严禁硬编码**或提交到 Git 仓库。
    * 使用 **GitHub Actions Secrets** 存储 CI/CD 流程中需要的凭证。
    * Cloudflare Worker 运行时密钥使用 **Cloudflare Secrets**。
    * GCP 服务运行时密钥（如果服务账号内置权限不足）可使用 **GCP Secret Manager**。
    * Vercel 前端需要的非敏感配置通过 **Vercel Environment Variables** 注入。
- **基础设施安全**:
    * Terraform 代码应接受审查，确保资源配置安全（例如，最小开放网络端口，安全的 IAM 策略）。
    * 定期审计 Cloudflare 和 GCP 的 IAM 权限。
- **输入验证**:
    * 所有外部输入（API 请求、Pub/Sub 消息）都必须使用 Zod 等工具进行严格验证。
- **依赖安全**:
    * 使用 Dependabot 或类似工具自动扫描和更新存在漏洞的依赖包。

---

## 🔁 架构演进与特性规划

- **核心MVP**: 打通 Vercel -> CF API -> DO -> Pub/Sub -> GCP Function/Run -> DO 回调 -> 存储 (R2/D1/GCS/Firestore) -> Vercel 前端展示 的完整图像处理和状态追踪链路。
- **可观测性增强**: 完善 Google Cloud Logging & Monitoring 中的仪表盘和告警，实现对多云架构的全面监控。
- **向量搜索集成**: 进一步开发 Cloudflare Vectorize 或 GCP Vertex AI Vector Search 的前端查询和结果展示功能。
- **DLQ 深度处理**: 细化 GCP Pub/Sub 死信主题消息的分析、重试和归档策略。
- **高级特性 (可选)**:
    * Feature Flags (例如使用 LaunchDarkly 或自建简单方案) 控制功能上线。
    * 进一步优化成本，例如根据负载调整 GCP Cloud Run 的并发和实例数，或利用GCS不同存储类别。
    * 引入更复杂的事件处理模式（如事件溯源、CQRS - 如果业务需要）。