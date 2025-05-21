# 🧪 testing-guidelines-20250521.md (架构版本 2025年5月21日)
📅 Updated: 2025-05-21

---
本指南概述了 iN 项目在 Vercel, Cloudflare, Google Cloud Platform (GCP) 多云架构下的测试策略和建议。

## 🎯 测试目标

- **确保核心功能正确性**: 验证图像处理任务从提交到完成的整个链路按预期工作。
- **保证代码质量**: 通过单元测试和静态分析尽早发现和修复 bug。
- **验证集成点**: 确保各服务组件（Vercel前端, CF API GW, CF DO, GCP Pub/Sub, GCP Functions/Run, GCP数据库等）之间能够正确交互。
- **提升系统稳定性与可靠性**: 通过模拟失败场景和边界条件测试，增强系统的鲁棒性。
- **支持自动化 CI/CD**: 所有关键测试都应能被 GitHub Actions 自动化执行。

##  layered-testing-approach">层级化测试策略 (测试金字塔)

| 测试类型         | 工具/框架 (示例)                                       | 覆盖内容与范围                                                                                                                                 | 执行频率/环境        |
| ---------------- | ------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------- | -------------------- |
| **单元测试 (Unit Tests)** | **Vitest**, Jest, Mocha/Chai                 | - `packages/shared-libs` 中的工具函数、类、逻辑模块。<br>- 各应用 (`apps/*`) 中的独立业务逻辑函数、纯组件 (前端)、辅助类。<br>- Mock 外部依赖。                | 本地开发中、CI每次提交 |
| **组件测试 (Component Tests - 前端)** | Vitest (带 `happy-dom`/`jsdom`), Testing Library (Svelte/React/Vue) | - Vercel 前端应用的单个UI组件的渲染、交互和状态变化。                                                                                               | 本地开发中、CI每次提交 |
| **集成测试 (Integration Tests)** | Vitest (用于Node.js环境的测试), **Wrangler CLI (Miniflare)**, **GCP Emulators (Pub/Sub, Firestore, Functions Framework)**, Postman/Newman, Supertest | - **CF Worker/DO**: 测试 API Gateway Worker 的路由、认证、请求处理；测试 `TaskCoordinatorDO` 的状态转换、与(模拟的)GCP服务回调交互。<br>- **GCP Functions/Run**: 测试服务对 Pub/Sub 消息的正确消费、与 Firestore/GCS 等GCP服务的交互、以及对 CF DO 的回调逻辑。<br>- 测试服务间的直接API调用 (如果存在)。<br>- 外部依赖（如真实GCP服务、真实DO）可被模拟器或测试桩 (test doubles) 替代。 | CI每次提交、预部署环境 |
| **端到端测试 (E2E Tests)** | Playwright, Cypress                                    | - 模拟真实用户场景，从 Vercel 前端 UI 操作开始，贯穿整个业务流程 (例如，用户登录 -> 配置并提交任务 -> 等待处理 -> 查看结果/状态)。<br>- 验证整个系统（Vercel-CF-GCP）的协同工作。 | CI (频率较低，如合并到dev/main后)、Staging环境 |
| **契约测试 (Contract Tests - 可选)** | Pact, Spring Cloud Contract                            | - (如果微服务间API交互复杂且由不同团队维护) 验证服务间 API 接口的兼容性，确保生产者和消费者的期望一致。                                                 | CI每次提交             |

---

## ✅ 各平台/组件测试要点

### 1. Vercel 前端 (例如 SvelteKit/Next.js)
   - **单元测试**: 使用 Vitest 测试 Svelte/React/Vue 组件的 props, slots, events, 核心逻辑函数。
   - **组件测试**: 使用 Testing Library 模拟用户交互，验证组件在 DOM 中的渲染和行为。
   - **E2E 测试**: Playwright/Cypress 驱动浏览器执行用户场景。
   - **Mocking**: 使用 MSW (Mock Service Worker) 或类似工具 Mock 对 Cloudflare API Gateway 的调用，以便独立测试前端逻辑。

### 2. Cloudflare Workers & Durable Objects
   - **单元测试 (Vitest)**: 测试 Worker/DO 内部的请求处理函数、状态更新逻辑、工具函数。Mock `Workspace` 调用和环境变量。
   - **集成测试 (Miniflare / `wrangler dev`)**:
        - 使用 Miniflare (Wrangler v3 及更早版本中集成，或作为独立包) 或 `wrangler dev` 的本地测试服务器。
        - 可以模拟 KV, R2, D1, DO 绑定，甚至模拟外部 `Workspace` 响应。
        - 测试 API Gateway Worker 的路由、CORS、认证转发、请求/响应转换。
        - 测试 `TaskCoordinatorDO` 的状态持久化、方法调用、以及对（模拟的）GCP Function/Run 回调的处理。

### 3. GCP Cloud Functions / Cloud Run
   - **单元测试 (Vitest/Jest)**: 测试函数/服务内部的业务逻辑，Mock Pub/Sub 消息体、Firestore 客户端、GCP SDK 调用等。
   - **集成测试 (GCP Emulators & Functions Framework)**:
        - 使用 **Functions Framework** 在本地运行 HTTP 或事件触发的函数。
        - 使用 **Pub/Sub Emulator** 模拟消息发布和订阅，触发本地函数。
        - 使用 **Firestore Emulator / Datastore Emulator** 测试数据库交互。
        - 测试函数对 Pub/Sub 消息的正确解析、业务处理、对 Firestore/GCS 的操作、以及对（模拟的）Cloudflare DO 的回调。
        - 可以编写测试脚本通过 `gcloud pubsub emulators push` 或客户端库向模拟器发消息。

### 4. `packages/shared-libs`
   - **单元测试 (Vitest)**: 必须有高覆盖率的单元测试，因为这是多方依赖的核心代码。

---

## ⚙️ CI/CD 中的自动化测试 (GitHub Actions)

- **PR触发**: 每次创建或更新 Pull Request 时，自动运行：
    - Lint & Format checks。
    * Unit Tests (所有应用和包)。
    * Component Tests (前端)。
    * (推荐) 部分关键路径的 Integration Tests (可能需要更复杂的环境搭建或mocking)。
- **合并到 `dev`/`main` 分支后触发**:
    * 所有上述测试。
    * 更全面的 Integration Tests (可能部署到临时的Staging/Test环境)。
    * E2E Tests (针对 Staging 环境)。
    * (可选) 契约测试。
    * (可选) 安全扫描 (SAST, DAST, 依赖扫描)。
- **测试报告**: 生成并归档测试报告和代码覆盖率报告。测试失败会阻塞合并或部署。

---

## 📈 测试覆盖率与质量目标

- **单元测试**: 核心共享库和关键业务逻辑模块力争达到 80%+ 的代码覆盖率。
- **集成测试**: 覆盖所有主要的服务间交互路径和关键用户场景。
- **E2E 测试**: 覆盖最重要的用户流程 (Happy Path)。
- **目标**: 通过全面的自动化测试，尽早发现缺陷，确保代码质量，增强重构信心，保障生产环境稳定。

---
文档名：testing-guidelines-20250521.md (原 testing-guidelines-20250422.md)
更新日期：2025-05-21