# 🧭 iN 项目最佳实践手册 (架构版本 2025年5月21日)
📄 文档名称：best-practices-20250521.md
🗓️ 更新时间：2025-05-21

---

## 📦 架构分层最佳实践

- **Vercel (前端层)**:
    - 使用现代前端框架 (如 SvelteKit/Next.js) 构建用户界面，并托管在 Vercel 平台，利用其全球 CDN 和部署优势。
    - 前端应用通过清晰定义的 API 与 Cloudflare API Gateway Worker 进行通信。
- **Cloudflare (边缘层)**:
    - 使用 Cloudflare Workers 作为 API Gateway，统一处理入站请求、路由、认证预处理、限流和基本校验。
    - Cloudflare Workers 也可用于执行轻量级的边缘计算逻辑。
    - Durable Objects (`TaskCoordinatorDO`) 用于任务的精细化状态管理和生命周期协调，确保单个任务流程的强一致性。
    - R2, D1, Vectorize 作为边缘存储，用于快速访问图片、元数据和向量数据。
- **Google Cloud Platform (GCP) (核心后端服务层)**:
    - 使用 Google Cloud Pub/Sub 作为核心任务链的消息队列，实现各处理阶段的异步解耦和可靠通信。
    - 使用 Google Cloud Functions 或 Cloud Run 部署核心业务逻辑处理单元（下载、元数据、AI分析），由 Pub/Sub 消息触发。
    - 使用 Google Cloud Identity Platform (GCIP) 进行全面的用户身份认证和管理。
    - 使用 GCP Firestore (Native Mode) / Datastore 存储用户配置和应用核心数据。
    - 使用 Google Cloud Logging & Monitoring 进行集中的日志管理和系统监控。
- **通用原则**:
    - 所有副作用逻辑抽出封装为共享库（`packages/shared-libs/*`）。
    - 核心任务流由 GCP Pub/Sub 驱动，GCP Functions/Run 消费逻辑保持幂等性。
    - 所有对外 API 接口前置 Cloudflare Gateway Worker 做统一处理。

---

## 🔐 安全最佳实践

- **身份认证与授权**:
    - **用户层面**: 使用 **Google Cloud Identity Platform (GCIP)** 进行用户注册、登录和身份验证，支持 OAuth (Google, GitHub 等)。
    - **服务层面 (Cloudflare Workers <-> GCP Services)**: Cloudflare Workers 调用 GCP 服务时，使用 GCP 服务账号 (Service Account) 凭证，遵循最小权限原则，凭证通过 Cloudflare Secrets 安全存储和注入。
    - **服务层面 (内部API)**: 如果 Cloudflare Workers 间或 GCP 服务间有直接调用，可根据需要使用 HMAC 签名或基于 IAM 的 token 进行验证。
- **密钥与配置管理**:
    - 所有敏感配置（API密钥、服务账号JSON、数据库密码等）通过各平台推荐的 Secrets Management 机制管理（Cloudflare Secrets, GCP Secret Manager, GitHub Actions Secrets, Vercel Environment Variables）。严禁硬编码到代码或版本控制中。
    - `.env.secrets` 文件可用于本地开发，但必须在 `.gitignore` 中排除。
- **日志与数据安全**:
    - 日志中禁止输出原始 token、API Key、密码、Cookie 等敏感信息。
    * 对用户数据和敏感业务数据进行适当的脱敏处理后再记录日志。
    * 数据库（D1, Firestore, GCS, R2）的数据访问权限应配置为最小必要。
- **API 安全**:
    * 所有 Cloudflare API Gateway Worker 暴露的接口需进行身份校验（基于 GCIP Token）和权限检查。
    * 考虑对公开 API 进行速率限制和输入验证 (例如使用 Zod)。
- **依赖安全**:
    * 定期扫描项目依赖，及时更新有漏洞的库。

---

## 🧩 前端开发最佳实践 (Vercel)

- 使用 SvelteKit (或选定的现代框架) 构建 SPA 或 SSR/SSG 应用，部署于 Vercel，配置支持基于 Vercel 环境变量区分不同环境 (production, preview, development)。
- 所有对 Cloudflare API Gateway 的调用封装在统一的客户端模块中，并处理认证 Token 的注入（从 GCIP 获取）和全局错误处理。
- 尽量使用公共组件与 Tailwind CSS (或选定的样式方案) 统一 UI 样式。
- 用户配置页面与状态列表页面分离，便于维护。

---

## 🧪 测试与 CI/CD 最佳实践 (GitHub Actions)

- **测试**:
    - 所有共享逻辑 (`packages/shared-libs`) 须编写 Vitest 单元测试，确保高覆盖率。
    - Cloudflare Workers 和 GCP Cloud Functions/Run 的核心业务逻辑也应有单元测试。
    - 集成测试：
        - Cloudflare Workers: 本地使用 `wrangler dev` 结合 mock 或真实（测试环境）的 DO 和 GCP 服务进行联调。
        - GCP Cloud Functions/Run: 使用 GCP 提供的本地模拟器（如 Functions Framework, Pub/Sub emulator）或直接部署到测试环境进行测试。
    - E2E 测试 (可选，推荐): 使用 Playwright 或 Cypress 测试从 Vercel 前端到后端 API 的完整用户流程。
- **CI/CD (GitHub Actions)**:
    - **GitHub Actions** 作为统一的 CI/CD 平台。
    - CI 流程应至少包括：代码 Lint 检查、单元测试、构建检查。
    - CD 流程应根据分支策略自动或手动触发部署到 Vercel (前端)、Cloudflare (Workers, DO等) 和 GCP (Functions/Run, Pub/Sub配置等) 的不同环境。
    - Terraform Plan/Apply 也应纳入 GitHub Actions 流程，用于基础设施的自动化管理。
    - 推送至主分支 (`main`) 或开发分支 (`dev`) 必须通过 Pull Request (PR) 审查，并确保 CI 检查通过。

---

## 📈 可观测性最佳实践 (GCP Logging & Monitoring)

- **日志**:
    - 所有服务（Vercel 前端日志导出, Cloudflare Workers, GCP Cloud Functions/Run）的日志统一通过结构化的方式输出 (JSON)，并包含 `traceId`。
    - Cloudflare Worker 日志通过 Logpush (或直接API) 推送到 GCP (例如，通过 Pub/Sub 管道导入 Cloud Logging)。
    - GCP 服务日志默认收集到 Cloud Logging。
    - Vercel 应用日志可以通过其提供的日志导出功能或 API 集成到 GCP Logging。
- **监控与告警**:
    - 使用 **Google Cloud Monitoring** 创建仪表盘，监控关键指标：
        - Vercel 前端性能指标。
        * Cloudflare Worker API 请求速率、错误率、延迟。
        * Cloudflare DO 运行状况。
        * GCP Pub/Sub 主题/订阅的消息积压量、处理速率。
        * GCP Cloud Functions/Run 执行次数、错误率、耗时。
        * 数据库 (D1, Firestore) 的性能指标。
    - 基于这些指标设置告警规则，及时发现和响应问题。
- **追踪**:
    - 确保 `traceId` 在跨服务调用中（Vercel -> Cloudflare API -> Pub/Sub -> GCP Function/Run -> DO）正确传递，以便在 GCP Logging & Monitoring 中进行端到端链路追踪。