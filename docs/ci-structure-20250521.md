# 📄 ci-cd-structure-20250521.md (原 ci-structure-20250422.md)
📅 Updated: 2025-05-21

## 当前 CI/CD 概况 (GitHub Actions)

- **CI/CD 工具**: **GitHub Actions**。
- **触发方式**: 主要由向特定分支 (如 `main`, `dev`) 推送代码或创建 Pull Request 时自动触发。
- **项目结构**: 采用 Monorepo (pnpm + Turborepo 管理)，GitHub Actions 工作流利用 Turborepo 的能力进行任务调度和缓存优化，只构建和测试受变更影响的应用和包。
- **目标平台**: Vercel (前端), Cloudflare (Workers, DO, R2, D1, Vectorize), Google Cloud Platform (Cloud Functions/Run, Pub/Sub, Firestore, GCS 等)。

## 工作流 (Workflow) 阶段划分示例 (在 `.github/workflows/*.yml` 中定义)

一个典型的 Pull Request 或推送到 `dev`/`main` 分支的 GitHub Actions 工作流可能包含以下主要阶段 (Jobs)：

1.  **Setup & Checkout**:
    * 检出代码。
    * 设置 Node.js, pnpm, Go (Terraform), gcloud CLI, Wrangler CLI 等所需环境。
    * 缓存依赖项 (pnpm store, Turborepo cache)。

2.  **Lint & Format**:
    * 运行 ESLint, Prettier (或选定的工具) 对代码进行静态分析和格式检查。

3.  **Unit Tests**:
    * 运行 Vitest (或选定的测试框架) 执行单元测试 (`packages/*`, `apps/*` 中的测试)。
    * (可选) 生成代码覆盖率报告。

4.  **Build**:
    * 使用 Turborepo (`pnpm turbo build`) 构建所有受影响的应用和包：
        * Vercel 前端应用。
        * Cloudflare Workers 和 DO。
        * GCP Cloud Functions/Run (如果需要构建步骤，例如 TypeScript 编译)。
        * 共享库。

5.  **Integration Tests (可选，根据环境配置)**:
    * 针对构建产物运行集成测试。
    * 可能需要部署到一个临时的测试环境或使用模拟器。

6.  **Infrastructure (Terraform - IaC)**:
    * `terraform fmt -check` (格式检查)。
    * `terraform validate` (配置验证)。
    * `terraform plan -out=tfplan` (生成执行计划，仅在PR或特定条件下执行 apply)。
        * 对于 PR，可以将 plan 的结果作为评论发布到 PR 中供审查。
    * `terraform apply tfplan` (应用变更，通常在合并到 `dev` 或 `main` 后针对对应环境执行)。

7.  **Deploy Applications**:
    * **Deploy Frontend to Vercel**:
        * 使用 Vercel CLI 或 Vercel GitHub Integration 自动部署。
    * **Deploy to Cloudflare**:
        * 使用 Wrangler CLI 部署 Workers, DOs, 并配置 R2, D1, Vectorize 等 (部分可能由Terraform管理)。
    * **Deploy to GCP**:
        * 使用 `gcloud` CLI 部署 Cloud Functions/Run 服务，配置 Pub/Sub 等 (部分可能由Terraform管理)。

8.  **Post-Deployment Smoke Tests / Health Checks (可选)**:
    * 对部署后的应用和服务进行基本的健康检查，确保部署成功。

9.  **Notifications**:
    * 将 CI/CD 的状态 (成功/失败) 通知到相关渠道 (例如 Slack, Email)。

## 密钥和环境变量管理

- **GitHub Actions Secrets**: 存储所有用于部署的敏感凭证，如 `CF_API_TOKEN`, `GCP_SERVICE_ACCOUNT_KEY`, `VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID`。
- **Vercel Environment Variables**: 用于前端应用的环境变量，区分 Production, Preview, Development。
- **Cloudflare Worker Secrets**: Worker 运行时需要的密钥。
- **GCP Secret Manager**: (可选) 用于存储 GCP 服务运行时需要的更细粒度的密钥，由 Cloud Functions/Run 在运行时拉取。

## 协作与分支保护建议 (GitHub)

- **分支保护**:
    * `main` 分支和 (可选) `dev` 分支启用分支保护规则。
    * 禁止直接推送到受保护分支，必须通过 Pull Request。
- **Pull Request (PR) 审查**:
    * PR 必须通过所有 CI 检查 (Lint, Test, Build, Terraform Plan (无错误))。
    * 需要至少一名 (或多名) Reviewer 批准才允许合并。
- **依赖扫描与安全检查**:
    * (可选) 集成如 Dependabot (GitHub原生) 进行依赖项漏洞扫描。
    * (可选) 集成如 Gitleaks 或类似的工具进行代码中的敏感信息泄露扫描。

通过上述结构和实践，可以构建一个健壮、自动化的 CI/CD 流程，支持向 Vercel, Cloudflare 和 GCP 的多平台部署。