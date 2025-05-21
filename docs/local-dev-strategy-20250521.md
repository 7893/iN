# 🛠 local-dev-strategy-20250521.md (架构版本 2025年5月21日)
_本地开发流程与多云模拟环境建议_

## ✅ 核心工具推荐

- **Vercel CLI**: 用于本地开发和调试 Vercel 前端应用。
- **Wrangler CLI**: 用于本地开发和测试 Cloudflare Workers 和 Durable Objects。
- **Google Cloud SDK (`gcloud` CLI)**: 用于与 GCP 服务交互、本地模拟和部署。
    - **Functions Framework**: 本地运行和测试 GCP Cloud Functions。
    - **Pub/Sub Emulator**: 本地模拟 GCP Pub/Sub 服务。
    - **Firestore Emulator**: 本地模拟 GCP Firestore 服务。
    - **Datastore Emulator**: 本地模拟 GCP Datastore 服务 (如果选择 Datastore)。
- **Node.js & pnpm**: 项目主要的运行时和包管理工具。
- **Docker**: (可选) 用于运行 GCP 模拟器或创建一致的开发环境。
- **Terraform CLI**: 本地规划和应用基础设施变更。
- **Vitest + tsx**: 本地执行单元测试和类型检查。
- **Postman / Insomnia / curl**: 用于 API 接口测试。

## ⚙️ 本地开发流程建议

### 1. 前端开发 (Vercel)
   - 在前端应用目录 (例如 `apps/in-pages`) 中运行 `vercel dev`。
   - Vercel CLI 会启动本地开发服务器，并可配置连接到本地或远程的 Cloudflare API Gateway。
   - 利用 GCIP 客户端 SDK 进行用户认证流程的本地调试（可能需要配置 GCIP 允许来自 `localhost` 的重定向URI）。

### 2. Cloudflare Workers & Durable Objects 开发
   - 在对应的 Worker/DO 应用目录 (例如 `apps/iN-worker-A-api-gateway-20250521`) 中运行 `wrangler dev`。
   - `wrangler.toml` 中可以配置本地绑定的服务（例如，指向本地运行的 GCP 服务模拟器或测试环境的 GCP 服务）。
   - **API Gateway Worker**: 测试其路由、认证转发 (GCIP Token 验证逻辑可能需要 mock 或连接测试 GCIP 环境)、请求转换、以及向本地 Pub/Sub Emulator 发布消息的逻辑。
   - **TaskCoordinatorDO**:
        - 可以通过 `wrangler dev` 启动的 Worker（如一个测试用的辅助 Worker）来直接调用 DO 的方法进行测试。
        - 测试其状态转换逻辑、对（模拟的）GCP Cloud Function 回调的处理。
        - DO 中调用外部服务（如 GCP Function）的部分，在本地可能需要 mock其响应，或配置 `wrangler dev` 将这些调用指向本地运行的 GCP Function 模拟实例。

### 3. GCP Cloud Functions / Cloud Run 开发
   - 在对应的 Function/Service 应用目录中：
        - 使用 **Functions Framework** 本地运行和调试 HTTP 触发的函数。
        - 对于 Pub/Sub 触发的函数，可以使用 **Pub/Sub Emulator**。通过 `gcloud` CLI 或客户端库向本地 Emulator 的主题发布消息，触发本地运行的函数。
        - 函数与 **Firestore Emulator / Datastore Emulator** 交互，进行数据库操作的本地测试。
        - 函数中调用 Cloudflare DO 的回调部分，需要配置其 `Workspace` 调用指向本地 `wrangler dev` 启动的 DO 实例的 URL，并处理本地开发环境的跨域和网络访问问题（可能需要工具如 `ngrok` 或配置本地 hosts）。

### 4. 共享库 (`packages/shared-libs`) 开发
   - 共享库的修改通过 pnpm workspaces 自动反映到依赖它们的应用中。
   - 编写并运行单元测试 (Vitest) 确保共享库的质量。

### 5. 基础设施 (Terraform) 开发
   - 在 `infra/` 目录中运行 `terraform plan` 和（针对个人开发环境的）`terraform apply`。
   - 确保本地安装并配置了 Cloudflare Provider 和 Google Cloud Provider。

## 🧪 自动化测试建议

- **单元测试**: 使用 Vitest + Mocks 对共享库、工具函数、以及各服务中可独立测试的业务逻辑模块进行测试。
- **集成测试 (本地模拟环境)**:
    * **Cloudflare**: `wrangler dev` + 脚本/Postman 测试 Worker 与 DO 交互，DO 与（模拟的）GCP Function 回调。
    * **GCP**: 使用 GCP Emulators + 脚本/Postman 测试 Function/Run 服务对 Pub/Sub 消息的处理、与 Firestore/Datastore 交互、以及对（模拟的）Cloudflare DO 回调。
- **CI 中的集成测试**: GitHub Actions 中可以考虑启动 GCP Emulators（例如使用 Docker 镜像）来进行更真实的集成测试。

## 📝 注意事项

- **多服务协同调试**: 同时运行 Vercel CLI, Wrangler CLI, GCP Functions Framework/Emulators 可能较为复杂。建议：
    * **逐个击破**: 先确保单个服务能独立本地运行和测试。
    * **Mocking**: 在测试一个服务时，Mock其依赖的其他服务，以减少本地环境搭建的复杂度。例如，测试 API Gateway Worker 时，可以 Mock 对 GCP Pub/Sub 的发布调用。
    * **统一的日志和 `traceId`**: 在所有本地运行的服务中都使用结构化日志，并确保 `traceId` 能在调用链中传递，便于追踪问题。
- **环境变量与密钥管理**:
    * 本地开发时，使用 `.env` 或类似机制管理各服务的环境变量和（测试用的）密钥。确保这些文件在 `.gitignore` 中。
    * 避免在本地使用生产环境的真实密钥。
- **网络穿透/代理**: 如果本地运行的 GCP Function 需要回调本地 `wrangler dev` 启动的 DO，可能需要使用 `ngrok` 之类的工具将本地 DO 服务暴露一个公网可访问的临时 URL。

此策略旨在提供一个尽可能接近生产环境的多云本地开发体验，同时兼顾效率和可操作性。