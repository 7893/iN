# 🧑‍💻 编码与风格规范 (架构版本 2025年5月21日)
📄 文档名称：coding-guidelines-20250521.md
🗓️ 更新时间：2025-05-21

---

## 🧱 通用规则

- **语言**:
    - 使用 **TypeScript** 编写所有业务逻辑，包括前端 (Vercel), Cloudflare Workers/DO, GCP Cloud Functions/Run, 以及共享库。
    - 启用并遵循严格的 TypeScript 编译器选项 (`strict: true` 等)。
- **风格**:
    - 遵循函数式编程风格：鼓励使用纯函数、不可变数据结构、高阶函数和组合。
    - 使用 Prettier 进行代码格式化，ESLint 进行代码质量和风格检查，配置需在项目根目录统一。
- **模块化**:
    - 所有模块需进行合理的模块化拆分，确保高内聚、低耦合。
    - 可复用的业务无关逻辑、类型定义、工具函数等应封装到 `packages/shared-libs/*` 中。
- **命名**:
    - 遵循项目已定义的 `naming-conventions-*.md` 文件中的规范。
    - 文件名、变量名、函数名、类名等采用一致的风格（例如，接口使用 `I` 前缀，类型使用 `T` 前缀或 PascalCase，常量全大写）。
- **错误处理**:
    - 清晰地处理错误和异常，避免隐藏错误。
    * 在适当的层级捕获并记录错误，返回对用户或调用方友好的错误信息。
    * 定义统一的错误码和错误响应结构。
- **注释与文档**:
    * 对复杂的逻辑、公共API、重要的数据结构编写清晰的 JSDoc/TSDoc 注释。
    * 保持代码的自解释性，避免不必要的注释。
- **异步处理**:
    * 优先使用 `async/await` 处理异步操作，确保 Promise 被正确处理（捕获 `reject` 或 `try/catch`）。

---

## ☁️ Cloudflare Worker & Durable Object 编码规范

- **结构**:
    * 每个 Worker/DO 应有独立的项目目录（在 `apps/` 下），包含独立的 `wrangler.toml` 和 `package.json`。
    * 命名规范需与 `naming-conventions-*.md` 一致。
- **共享库依赖**:
    * 所有 Cloudflare Workers/DO 必须使用 `packages/shared-libs/logger.ts` (结构化日志), `packages/shared-libs/trace.ts` (traceId 传递)。
    * 认证相关逻辑（如 GCIP Token 验证辅助函数）应封装在 `packages/shared-libs/auth.ts` 中，由 API Gateway Worker 调用。
- **Durable Object (`TaskCoordinatorDO`)**:
    * 作为状态机和协调器，其内部逻辑应清晰划分状态转换、对GCP Functions/Run的调用、以及处理来自GCP Functions/Run的回调。
    * 所有状态操作需持久化到 `this.state.storage`。
    * 确保对存储的操作是原子的或幂等的，以维护状态一致性。
    * 禁止在 DO 内部执行长时间阻塞操作；需要长时间运行的任务应委托给 GCP Cloud Functions/Run。
- **API Gateway Worker**:
    * 负责请求路由、版本控制、认证（调用 `shared-libs/auth.ts` 验证 GCIP Token）、基本输入校验、向 GCP Pub/Sub 发布初始任务消息。
- **与 GCP 服务交互**:
    * Worker 调用 GCP 服务（如 Pub/Sub, Firestore, GCIP）时，需使用 GCP 客户端库 (如果适用且能在 Worker 环境运行) 或直接调用其 HTTP API。
    * 服务账号密钥等凭证必须通过 Cloudflare Secrets 安全管理和注入，不得硬编码。

---

## 🚀 GCP Cloud Functions / Cloud Run 编码规范

- **触发器**:
    * 主要由 GCP Pub/Sub 消息触发。函数/服务需要正确解析 Pub/Sub 消息体。
    * (可选) 也可配置为 HTTP 触发器，供内部服务调用或 Cloudflare Worker 直接调用。
- **职责单一**:
    * 每个 Function/Service 应专注于单一业务逻辑（例如，下载、元数据提取、AI分析）。
- **幂等性**:
    * 所有由 Pub/Sub 触发的 Function/Service 必须实现幂等性，因为 Pub/Sub 保证至少一次消息传递。
- **状态与回调**:
    * Function/Service 在执行核心逻辑后，必须通过 `Workspace` **回调** Cloudflare `TaskCoordinatorDO` 的 `/reportStatus` 接口，报告其执行结果（成功/失败、输出数据、错误信息）。
    * 如果是多阶段流程中的一环，成功处理后还需要向 GCP Pub/Sub 的下一个主题发布消息。
- **共享库依赖**:
    * 同样应使用 `packages/shared-libs/logger.ts` (配置为输出到 Google Cloud Logging), `packages/shared-libs/trace.ts` (处理传入的 traceId 并传递下去)。
- **错误处理与日志**:
    * 错误需要被捕获，并通过回调 `TaskCoordinatorDO` 报告。
    * 所有日志输出到标准输出/错误流，GCP 会自动收集到 Cloud Logging。日志必须为结构化 JSON。
- **依赖管理**:
    * 使用 `package.json` 管理 Node.js 依赖。
    * 确保部署包尽可能小，只包含运行时必要的依赖。
- **环境变量与密钥**:
    * 运行时配置通过环境变量注入。
    * 敏感信息（如访问其他 GCP 服务的密钥，尽管推荐使用服务账号的内置权限）通过 GCP Secret Manager 管理（如果 Cloud Functions/Run 配置直接访问）或由调用方 (DO) 传递。

---

## 🎨 前端 (Vercel + SvelteKit/Next.js) 编码规范

- **结构**:
    * 前端项目（在 `apps/in-pages` 或类似目录）按选定框架 (如 SvelteKit/Next.js) 的标准项目结构组织。
    * 页面按路由结构划分，合理使用 Layout 组件。
- **API 调用**:
    * 所有对 Cloudflare API Gateway 的 HTTP 请求应封装在专用的 API 客户端模块中 (`lib/api.ts` 或类似)。
    * 客户端模块负责处理 GCIP ID Token 的获取与注入到请求头 (Authorization Bearer Token)，以及统一的错误处理逻辑。
- **状态管理**:
    * 根据应用复杂度选择合适的状态管理方案 (Svelte Stores, Zustand, Redux Toolkit 等)。
- **样式**:
    * 推荐使用 Tailwind CSS 或其他 CSS-in-JS / CSS Modules 方案，避免全局 CSS污染和内联样式。
- **环境变量**:
    * 所有需要暴露给前端的配置（如 Cloudflare API Gateway URL, GCIP 项目配置参数）必须通过 Vercel 的环境变量注入，并以 `NEXT_PUBLIC_` (Next.js) 或 `PUBLIC_` / `VITE_` (SvelteKit/Vite) 等约定的前缀命名。
    * 严禁在前端代码中硬编码任何密钥或敏感后端地址。
- **测试**:
    * 关键组件和逻辑应编写单元测试 (Vitest/Jest) 和组件测试 (Testing Library)。

---

## 🔐 安全与验证编码规范

- **输入验证**:
    * 所有外部输入（API Gateway Worker 接收的请求体/参数, GCP Function/Run 从 Pub/Sub 接收的消息体）必须使用如 Zod 等库进行严格的模式校验和类型验证。
- **输出编码**:
    * 在前端展示用户输入或从后端获取的数据时，确保进行适当的 HTML 编码以防止 XSS 攻击。
- **认证与授权**:
    * API Gateway Worker 必须验证来自前端的 GCIP ID Token。
    * 后续的 Cloudflare Worker 或 GCP 服务如果需要进一步的权限控制，应基于已验证的用户身份进行。
- **敏感数据处理**:
    * 遵循最小信息原则，仅在必要时处理和传递敏感数据。
    * 日志输出必须经过审查，确保不包含未脱敏的个人身份信息 (PII) 或其他敏感字段。
- **依赖安全**:
    * 使用 `npm audit` 或 GitHub Dependabot 等工具定期检查并修复第三方库的安全漏洞。