# 🌿 Git 分支策略规范 (架构版本 2025年5月21日)
📄 文档名称：branch-strategy-20250521.md
🗓️ 更新时间：2025-05-21

---

## 📁 主分支定义 (GitHub)

| 分支名      | 用途                                     | 自动部署 (通过 GitHub Actions)                                                                 | 受保护规则 (GitHub)        |
| ----------- | ---------------------------------------- | ---------------------------------------------------------------------------------------------- | -------------------------- |
| `main`      | 主生产分支，代码稳定，代表已发布版本     | ✅ **Vercel Production** (前端)<br>✅ **Cloudflare Production** (Workers, DO等)<br>✅ **GCP Production** (Functions/Run等) | 必须通过PR合并，需要审查，CI通过 |
| `dev`       | 主开发分支，集成所有已完成的功能和修复     | ✅ **Vercel Preview** (前端)<br>✅ **Cloudflare Staging/Dev** (Workers, DO等)<br>✅ **GCP Staging/Dev** (Functions/Run等)  | 允许直接推送 (或宽松PR)    |
| `feature/*` | 新功能开发分支，从 `dev` 创建，完成后合并回 `dev` | ❌ 通常不自动部署，或部署到临时的个人开发环境/Vercel Preview                                      | 无特殊保护                 |
| `hotfix/*`  | 生产环境紧急Bug修复分支，从 `main` 创建    | 🔄 修复后合并到 `main` 和 `dev`，触发生产和开发环境部署                                               | 严格PR，紧急通道           |
| `release/*` | (可选) 预发布分支，从 `dev` 创建，用于准备发布到 `main` | 🟡 可能部署到预发布环境 (Staging) 进行最终测试                                                    | 类似 `main` 的保护         |
| `docs/*`    | 文档维护分支，从 `dev` 或 `main` 创建      | ❌ 通常不触发应用部署，可能触发文档站点的更新 (如果适用)                                              | 无特殊保护                 |

*注：Cloudflare 和 GCP 的环境管理可能通过 Terraform workspace 或不同的服务命名来实现。*

---

## 🧪 流程建议 (GitHub Flow / Gitflow Hybrid)

1.  **功能开发**:
    * 从最新的 `dev` 分支创建 `feature/your-feature-name` 分支。
    * 完成功能开发和本地测试。
    * 提交代码到 `feature/*` 分支。
    * 创建 Pull Request (PR) 请求合并到 `dev` 分支。
    * PR 需要至少一名团队成员 Review，并通过所有自动化检查 (Lint, Unit Tests, Build)。
    * 合并 PR 到 `dev` 分支，GitHub Actions 自动部署到开发/预览环境。

2.  **发布到生产**:
    * (可选) 当 `dev` 分支达到一个稳定状态，准备发布时，可以创建一个 `release/vX.Y.Z` 分支进行预发布测试。
    * 预发布测试通过后，将 `release/*` 分支（或直接从 `dev` 分支，如果流程简化）合并到 `main` 分支 (通过 PR，需要严格审查和最终CI通过)。
    * 合并到 `main` 后，GitHub Actions 自动部署到生产环境。
    * 在 `main` 分支上为该版本打上 Git Tag (例如 `v0.1.0`)。

3.  **紧急修复 (Hotfix)**:
    * 从最新的 `main` 分支创建 `hotfix/issue-description` 分支。
    * 进行修复并通过测试。
    * 创建 PR 合并回 `main` 分支，并同时确保该修复也合并回 `dev` 分支（通常在合并到 `main` 后，再将 `main` 合并回 `dev`，或将 `hotfix/*` 分支分别合并到 `main` 和 `dev`）。
    * 触发生产环境的紧急部署。

---

## 🔁 与 Vercel, Cloudflare, GCP 的 CI/CD 配合 (通过 GitHub Actions)

- **GitHub Actions** 作为统一的 CI/CD 中心。
- **Vercel**:
    * `dev` 分支的提交自动触发 Vercel Preview 环境的部署。
    * `main` 分支的提交自动触发 Vercel Production 环境的部署。
    * Vercel 环境变量通过 Vercel UI 或其 CLI 进行管理，并可通过 `VERCEL_ENV` 识别当前环境 (`production`, `preview`, `development`)。
- **Cloudflare & GCP**:
    * GitHub Actions 工作流将包含使用 Terraform (或其他 IaC 工具) 和各平台 CLI (Wrangler CLI, gcloud CLI) 的步骤来部署 Workers, DOs, Cloud Functions/Run, Pub/Sub 配置等。
    * 不同分支 (`main`, `dev`) 的部署可以指向不同环境的 Cloudflare 服务和 GCP 项目/服务配置（例如，通过 Terraform workspaces 或不同的配置文件/变量）。
    * 所有部署凭证 (Cloudflare API Token, GCP Service Account Key, Vercel Token) 必须存储在 GitHub Actions Secrets 中，并在工作流中安全使用。

---

## ✅ 分支保护规则 (在 GitHub 仓库设置中配置)

- `main` 分支:
    * **Require a pull request before merging**: 必须通过 PR 合并。
    * **Require approvals**: 至少需要 X 名 Reviewer 批准。
    * **Require status checks to pass before merging**: 所有 CI (Lint, Test, Build等) 必须成功。
    * **Include administrators**: 管理员也需遵守这些规则。
    * (可选) **Require linear history**: 禁止合并提交，保持历史整洁。
- `dev` 分支:
    * 可以设置相对宽松的规则，例如允许直接推送，或者只需要 CI 通过即可合并 PR (根据团队规模和协作模式决定)。

此分支策略旨在确保代码质量、团队协作效率以及生产环境的稳定性。