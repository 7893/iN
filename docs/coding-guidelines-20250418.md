[2025-04-18 18:30:57 JST]
好的，我们现在结合之前所有的讨论、您提供的项目文件信息（包括 `tree` 输出、各种文档和报告）、我对项目架构和技术栈的理解，以及您刚刚提供的 V1.0 指南模板，来编写一份尽可能详细的 **iN 项目编码与编程规则（超详细版 V1.1）**。我将遵循纯文本格式。

---
**iN 项目编码与编程规则 (超详细版 V1.1)**

**版本**: 1.1
**更新时间**: 2025-04-18 18:30 JST
**目的**: 本文档旨在为 iN 项目提供一套全面、详细的编码标准、编程范式和协作流程规范，确保代码的高质量、一致性、可维护性、可测试性、安全性和可扩展性。所有项目成员应严格遵守。

**目录**
1.  项目目录与层次结构
2.  通用工程原则
3.  TypeScript 语言规范与代码格式化
4.  函数式编程实践指南
5.  命名规范（全范围）
6.  文件与模块组织
7.  接口 / 数据传输对象 (DTO) / 事件契约
8.  异步编程、错误处理与重试机制
9.  日志、追踪与可观测性体系
10. 测试策略与测试金字塔
11. 性能考量与资源优化
12. 安全最佳实践
13. CI/CD 集成、校验与门禁
14. 文档、代码注释与版本管理
15. Pull Request (PR) 与代码审查流程
16. 参考资源

---

**1. 项目目录与层次结构**

项目遵循 Monorepo 结构，使用 pnpm + Turborepo 进行管理。核心目录结构如下：

```
/ (iN 项目根目录)
├── apps/                  # 可独立部署的应用单元
│   ├─ in-pages/          # 前端应用 (Cloudflare Pages 部署)
│   ├─ iN-worker-a-*/     # API 型 Worker (如 api-gateway, user-api)
│   ├─ iN-worker-c-*/     # 任务型 Worker (如 config, download, queue consumers)
│   └─ iN-do-a-*/         # Durable Object 实现 Worker
├── packages/              # 可共享的代码包
│   ├─ shared/            # 底层通用工具库 (logger, trace, auth, utils, etc.)
│   ├─ worker-logic/      # 【核心业务逻辑】按领域分组的纯业务逻辑包 (设计基于 V1.1 讨论)
│   │   ├─ image-processing-logic/ # 图像处理相关核心逻辑
│   │   └─ task-management-logic/  # 任务管理/状态协调相关核心逻辑
│   ├─ xxx-worker-logic/  # 【备选/待确认】特定 Worker 的独立逻辑包 (如果未使用 worker-logic 分组模式)
│   ├─ types/             # 跨包共享的 TypeScript 类型定义
│   ├─ ui/                # (可选) 共享前端 UI 组件库
│   ├─ eslint-config/     # 共享 ESLint 配置包
│   └─ typescript-config/ # 共享 TypeScript 配置包
├── infra/                 # 基础设施即代码 (Terraform)
│   └─ (推荐按资源类型分子目录: workers/, queues/, d1/, etc.)
├── docs/                  # 项目文档 (设计、报告、ADR 等)
├── tools/                 # 辅助工具脚本 (如 secrets 同步)
├── .github/ or .gitlab/   # (可选) CI/CD 配置文件目录
├── .gitignore             # Git 忽略配置
├── package.json           # Monorepo 根 package.json
├── pnpm-lock.yaml         # pnpm 依赖锁定文件
├── pnpm-workspace.yaml    # pnpm 工作区配置文件
├── README.md              # 项目说明文档
├── tsconfig.base.json     # 基础 TypeScript 配置
├── eslint.config.mjs    # ESLint 配置文件 (Flat Config)
├── vitest.config.ts       # Vitest 测试配置文件
└── turbo.json             # Turborepo 配置文件
```

* **分层职责**:
    * `apps/`: 处理边界交互（HTTP 请求/响应、Queue 消息、DO 调用），编排业务流程，调用 `packages/` 中的逻辑，管理副作用。
    * `packages/worker-logic/` (或 `packages/xxx-worker-logic`): 实现核心业务规则和算法，应尽可能为纯函数或副作用最小化。
    * `packages/shared`: 提供与业务领域无关的横切关注点解决方案（日志、追踪、认证、通用工具）。
    * `infra/`: 定义和管理所有 Cloudflare 基础设施资源。目标是 100% 由 IaC 管理。

**2. 通用工程原则**

* **清晰性优先**: 代码首先要易于人类阅读和理解，避免使用过于复杂或晦涩的语言特性。编写自解释的代码，辅以必要的注释。
* **单一职责原则 (SRP)**: 每个函数、类、模块、包、Worker 都应有明确且单一的职责边界。
* **DRY (Don't Repeat Yourself)**: 严格避免重复代码。发现重复逻辑时，应将其抽象到 `packages/shared` 或相应的逻辑包 (`worker-logic` 等) 中。
* **幂等性 (Idempotency)**: 所有**必须**实现幂等性的地方（尤其是 Queue 消费者）要确保逻辑健壮，可安全重试。
* **可追踪性 (Traceability)**: 所有请求和异步任务必须贯穿 `traceId`，并记录在日志中，便于问题排查和链路分析。
* **纯函数优先**: 在业务逻辑实现中，优先编写纯函数。将副作用（I/O、状态变更、外部调用）明确标识并隔离到系统边缘。
* **演进式设计**: 架构和代码应考虑未来的可扩展性，预留接口或使用设计模式，避免过度设计，但要易于后续迭代。
* **一致性**: 严格遵守本文档定义的各项规范，保持整个代码库风格、模式、命名的一致性。

**3. TypeScript 语言规范与代码格式化**

* **编译器选项**: 必须在 `tsconfig.json` (及继承的 `tsconfig.base.json`) 中启用所有 `strict` 相关的检查 (如 `strict: true`, `noImplicitAny`, `strictNullChecks`, `noUncheckedIndexedAccess: true`)。
* **禁止 `any`**: 严禁随意使用 `any` 类型。在无法确定类型时，使用 `unknown` 并配合类型守卫（如 `typeof`, `instanceof`, 自定义类型谓词）进行类型收窄。
* **类型与接口**: 使用 `interface` 定义对象的结构（shape），使用 `type` 定义联合类型、交叉类型、元组、函数签名或基本类型的别名。
* **不可变性**: 积极使用 `readonly` 修饰符标记类的属性、数组 (`ReadonlyArray<T>`) 或元组，以及 `Readonly<T>` 工具类型，明确表示数据不应被修改。
* **模块导入**: 使用 ES Modules (`import`/`export`)。使用 `import type { ... } from '...'` 语法导入纯类型定义，这有助于减小最终打包体积并明确意图。
* **代码格式化**:
    * **ESLint**: 必须启用。配置来源于 `packages/eslint-config` (通过根目录 `eslint.config.mjs` 加载)，使用 `@typescript-eslint/eslint-plugin` 等插件。所有代码提交前必须通过 lint 检查。
    * **Prettier**: (推荐) 使用 Prettier 自动格式化代码。配置文件（如 `.prettierrc.js` 或 `package.json` 中的 `prettier` 字段）应共享，推荐设置 `printWidth: 100` (行宽 100), `singleQuote: true` (使用单引号)。
    * **编辑器集成**: 必须配置开发环境编辑器（如 VS Code）自动运行 ESLint 检查和 Prettier 格式化。

**4. 函数式编程实践指南**

* **核心原则**: 在 `packages/worker-logic` 或 `packages/xxx-worker-logic` 中实现核心业务逻辑时，以及在 `packages/shared` 中编写工具函数时，应最大程度遵循函数式编程原则。
* **纯函数 (Pure Functions)**:
    * 函数的返回值仅由其输入参数决定。
    * 函数执行过程中不产生任何可观察的副作用（如修改外部变量、I/O 操作、调用 `console.log` 或我们的 `logger`）。
    * **示例**: 一个接收图片元数据对象，返回处理后标签数组的函数。
* **不可变性 (Immutability)**:
    * 绝不直接修改传入的对象或数组参数。
    * 如果需要返回修改后的版本，应创建新的对象或数组（例如使用对象扩展 `...`, 数组扩展 `...`, `Array.map`, `Array.filter` 等）。
    * **示例**: `return { ...taskState, status: 'COMPLETED', completedAt: new Date() };`
* **函数组合 (Function Composition)**:
    * 将复杂的操作分解为一系列简单、单一职责的函数。
    * 使用函数组合（如 Ramda, lodash/fp 的 `pipe` 或 `compose`，或手动嵌套调用）将这些小函数串联起来，构建复杂的处理流程。
    * **示例**: `const processTask = pipe(validateInput, fetchData, transformData, updateState);`
* **副作用隔离 (Side Effect Isolation)**:
    * 将必须执行的副作用（如数据库写入、队列发送、调用外部 API、记录日志）限制在尽可能小的范围内，通常是在 `apps/` 下的 Worker 主处理函数（`Workspace`, `queue`）或明确标记为执行副作用的函数（可能在 `shared` 中提供辅助函数，但调用点应清晰）。
    * 业务逻辑函数应返回数据或指令，由调用者（通常是 Worker）来执行实际的副作用。
    * **示例**: 逻辑函数返回 `{ dataToSave: {...}, messageToSend: {...} }`，由 Worker 负责调用 D1 写入和 Queue 发送。
* **幂等性 (Idempotency)**:
    * **强制要求**: 所有 `queue()` 处理器必须实现幂等性。
    * **实现方式**: 在执行核心处理逻辑之前，必须检查当前任务的状态（通常通过查询 Task Coordinator DO）。如果任务已处于“处理中”或“已完成”等后续状态，则应直接确认消息（ack）并返回，避免重复执行。
    * **示例**:
        ```typescript
        async queue(message, env, ctx) {
          const { taskId, traceId } = message.body; // Assuming message body structure
          const doId = env.TASK_COORDINATOR.idFromName(taskId);
          const stub = env.TASK_COORDINATOR.get(doId);
          const currentState = await stub.getState(); // Method in DO

          if (currentState === 'DOWNLOADING' || currentState === 'COMPLETED' || currentState === 'FAILED') {
             console.log(`Task ${taskId} already processed or in progress (${currentState}). Skipping.`);
             await message.ack(); // Acknowledge message
             return;
          }

          // Set state to 'PROCESSING' in DO (optional, depends on state machine)
          // await stub.setState('PROCESSING'); // Needs error handling

          try {
             // --->>> Execute core processing logic here <<<---
             // ... process message.body ...

             // Update DO state upon success
             await stub.setState('COMPLETED'); // Or next state
             await message.ack(); // Acknowledge message only on full success
          } catch (error) {
             // Log error with traceId, taskId
             // Optionally update DO state to FAILED
             // Do NOT ack message, let it retry or go to DLQ
             console.error("Processing failed:", error);
             // Consider message.retry() based on error type? Or rely on queue config.
          }
        }
        ```

**5. 命名规范（全范围）**

* **基础设施资源**: 遵循 `iN-naming-conventions-updated.md`。小写，连字符，`iN-`/`in-` 前缀，类型，字母，日期。
* **代码目录**:
    * `apps/`: `iN-worker-<letter>-<name>-<date>`, `iN-do-<letter>-<name>-<date>`, `in-pages`。
    * `packages/`: `kebab-case` (小写连字符)，如 `shared`, `worker-logic`, `image-processing-logic`, `eslint-config`。
    * `infra/` (分类结构): `kebab-case` (资源类型小写)，如 `workers`, `queues`。
* **代码文件**: `kebab-case.ts`。测试文件 `*.test.ts` 或 `*.spec.ts`。
* **变量/函数参数**: `camelCase`。布尔值变量/函数建议用 `is`, `has`, `should` 等开头。
* **常量**: `UPPER_SNAKE_CASE`。
* **函数/方法**: `camelCase`。应为动词或动词短语，清晰表达其作用。
* **类/类型/接口/枚举**: `PascalCase`。
* **私有成员**: 使用 TypeScript `private` 或 `protected` 关键字。避免使用下划线 `_` 前缀表示私有（除非特殊情况如 JS 兼容）。

**6. 文件与模块组织**

* **文件长度**: 单个 TypeScript 文件（`.ts`）的代码行数（不含空行和注释）**建议不超过 400 行**。超过此长度应考虑拆分成更小的模块。
* **`index.ts` 用途**: 目录下的 `index.ts` 文件**仅用于**聚合和导出该目录下的公共接口、类、函数或常量 (`export * from './module';` 或 `export { specificThing } from './module';`)。**禁止**在 `index.ts` 中编写实际的实现逻辑。
* **依赖方向**: 代码的依赖关系应尽可能单向。`apps/` 可以依赖 `packages/`。`packages/` 内部避免循环依赖。`packages/shared` 应位于依赖链的最底层。业务逻辑包 (`worker-logic` 等) 不应依赖 `apps/`。
* **公共 DTO/类型**: 跨多个包（尤其是 `apps/` 和 `packages/` 之间）共享的数据结构、类型定义应放在 `packages/types/` 目录下。

**7. 接口 / 数据传输对象 (DTO) / 事件契约**

* **REST API (HTTP)**:
    * **路径**: 使用复数名词表示资源集合（`/images`, `/users/{userId}/tasks`）。使用 Kebab-case 做路径参数（如果需要）。
    * **请求体验证**: **必须**使用如 Zod 或 Valibot 等库对 API 请求体 (Body) 和查询参数 (Query) 进行严格的 Schema 验证。验证失败应返回 400 Bad Request。
    * **响应体**: 成功响应使用标准 HTTP 状态码 (200, 201, 204)。响应体结构清晰、一致。
    * **错误响应**: **必须**返回统一的 JSON 错误格式，包含机器可读的错误码、人类可读的错误信息和用于追踪的 `traceId`。**示例**:
        ```json
        {
          "error": {
            "code": "RESOURCE_NOT_FOUND", // Or AUTH_ERROR, INVALID_INPUT, INTERNAL_SERVER_ERROR etc.
            "message": "Image with ID '...' not found.",
            "traceId": "b7a3c1f0-..."
          }
        }
        ```
* **队列消息 (Queue Payloads)**:
    * 消息体**必须**包含 `taskId` (如果适用) 和 `traceId` 以便追踪。
    * 消息体结构应清晰、一致，推荐在 `packages/types` 中定义接口。
* **事件契约 (如果未来启用 Event Queues)**:
    * (基于之前文档保留的定义) 定义统一的事件接口 `INEvent<T>`。
    * **示例**:
        ```typescript
        interface INEvent<T> {
          id: string;           // Unique event ID (e.g., UUID)
          type: string;         // Event type name (e.g., 'image.downloaded', 'task.completed')
          source: string;       // Service/Worker that generated the event (e.g., 'iN-worker-d-download')
          data: T;              // Event-specific payload/data
          timestamp: string;    // ISO 8601 timestamp of event occurrence
          traceId: string;      // Trace ID for correlation
          taskId?: string;     // Associated Task ID, if applicable
          userId?: string;     // Associated User ID, if applicable
          version: string;      // Event schema version (e.g., '1.0')
        }
        ```
    * 事件类型名称 (`type`) 使用 `domain.action` 格式，小写，点分隔。

**8. 异步编程、错误处理与重试机制**

* **`async/await`**: 统一使用，保持代码同步风格的可读性。
* **错误分类与处理**:
    * **业务逻辑错误 (可预期)**: 用户输入无效、资源未找到、权限不足等。应捕获这些错误，记录 WARN 或 INFO 级别的日志，并向客户端返回明确的错误响应（如 4xx状态码 + 标准错误 JSON）。可以使用自定义错误类 (如 `class ValidationError extends Error {}`)。
    * **系统/运行时错误 (非预期)**: 依赖服务（D1, R2, DO, Queues, 外部 API）不可用、代码 Bug、资源耗尽等。应捕获这些错误，记录 **ERROR** 级别的详细日志（包括堆栈跟踪），并向客户端返回通用的 500 Internal Server Error 响应。
* **Promise 拒绝**: 确保所有 Promise (尤其是 `await` 的调用) 都有处理拒绝的机制 (`try/catch` 或 `.catch()`)，防止出现 `unhandledRejection`。
* **重试策略 (针对队列消息或外部调用)**:
    * **队列**: 主要依赖 Cloudflare Queues 自身的重试机制和 DLQ 配置。Worker 代码层面通常不需要实现复杂的重试逻辑，除非需要基于特定错误类型进行条件重试 (`message.retry()`)。
    * **外部 API 调用**: (可选) 对于关键的外部 API 调用，可实现简单的重试逻辑，推荐采用**指数退避 (Exponential Backoff)** 策略（例如，等待 1s, 2s, 4s...），并设置最大重试次数（例如 3 次）。可以使用 `async-retry` 等库。
* **队列消息确认 (Ack)**:
    * **必须**只在消息被**完全成功处理**后才调用 `message.ack()`。
    * 如果处理过程中发生任何应导致重试或进入 DLQ 的错误，**绝不能**调用 `message.ack()`。

**9. 日志、追踪与可观测性体系**

* **统一日志库**: **必须**使用 `packages/shared/logger.ts` 中封装的日志记录器。**严禁**直接使用 `console.log`, `console.error` 等进行常规应用日志记录（`console` 可用于 DO 或极其临时的调试）。
* **结构化日志**: 日志**必须**输出为 **JSON** 格式。
* **核心字段**: 每条日志记录**必须**包含以下字段：
    * `timestamp`: ISO 8601 格式时间戳。
    * `level`: 日志级别 (e.g., 'debug', 'info', 'warn', 'error')。
    * `message`: 日志主体信息。
    * `traceId`: 当前请求/任务的追踪 ID。
    * `workerName`: 当前执行代码的 Worker 名称 (可从 `env` 或硬编码获取)。
    * `taskId`: (如果适用) 当前处理的任务 ID。
    * (可选) `userId`, `operationName`, `durationMs`, `errorStack`, 等其他上下文信息。
* **追踪 ID (`traceId`)**:
    * **必须**在请求入口处（API Gateway `Workspace` 处理器）或任务发起处（`config-worker`）生成 `traceId` (使用 `packages/shared/trace.ts`)。
    * **必须**通过 HTTP Headers (如 `X-Trace-ID`)、Queue 消息体、DO 调用参数等方式，在整个调用链中向下传递 `traceId`。
    * **必须**在每个 Worker 或 DO 的处理函数开始时，从输入中提取 `traceId`，并设置到日志记录器的上下文中。
* **日志平台与监控**:
    * 所有日志通过 Cloudflare Logpush 推送到指定平台（如 Axiom）。
    * (目标) 在 Axiom 中配置仪表盘，监控关键指标：Queue 消息数量、积压时间、DLQ 数量；Worker 调用次数、执行时间 (P95/P99)、错误率；DO 执行时间、错误率；D1 查询延迟。
    * (目标) 配置关键告警：DLQ 非空、Worker 错误率飙升、关键任务处理超时等。

**10. 测试策略与测试金字塔**

* **测试框架**: 使用 **Vitest**。
* **测试金字塔模型**:
    * **单元测试 (Unit Tests)**: (占比最高)
        * **工具**: Vitest。
        * **目标**: 测试单个函数、模块或类的逻辑正确性，特别是 `packages/` 下的纯函数和工具函数。
        * **要求**: 速度快，不依赖外部环境（无网络、无 IO），使用纯粹的输入和断言。
    * **集成测试 (Integration Tests)**: (占比中等)
        * **工具**: Vitest + Mocking (如 `vi.mock`, `vi.spyOn`) + Cloudflare 环境模拟 (Miniflare 或 Vitest 的 `cloudflare` 环境 - 需确认兼容性)。
        * **目标**: 测试模块间的交互。例如：
            * Worker 调用 `shared` 或 `worker-logic` 中的函数。
            * Worker 与模拟的 Cloudflare 绑定（如 Mock D1, Mock Queue, Mock DO）的交互。
            * API Worker 的路由和基本请求处理逻辑。
        * **要求**: 模拟外部依赖，验证组件协作是否符合预期。
    * **端到端测试 (E2E Tests)**: (占比最低，计划中)
        * **工具**: Playwright 或 Cypress。
        * **目标**: 模拟真实用户场景，通过前端 UI 或直接调用 API，验证整个系统的核心业务流程（如用户登录 -> 触发任务 -> 查询结果）。
        * **要求**: 需要部署一个可测试的环境（本地 `wrangler dev` 组合或 Staging 环境），测试较慢，主要覆盖关键路径。
* **测试覆盖率**:
    * (目标) `packages/shared` 和 `packages/worker-logic` (如果使用) 等核心逻辑库的**单元测试覆盖率应 > 80%**。
    * (目标) 整体代码覆盖率作为参考指标，并在 CI 中报告。
* **测试执行**: 所有测试必须可通过 `turbo run test` 在本地和 CI 环境执行。CI 中的测试失败**必须**阻止代码合并。

**11. 性能考量与资源优化**

* **Worker 资源**:
    * (目标) 关注 Worker 的 CPU 执行时间和内存使用。保持 Worker 轻量，避免长时间运行或内存密集型操作。CPU 密集任务（如复杂的 AI 推理）应委托给外部服务或 Cloudflare AI。
    * (目标) 单次 Worker 执行内存消耗**建议 < 128 MiB**。
* **Durable Objects (DO)**:
    * (目标) DO 的单次操作（读/写状态）**建议 < 30ms**。避免在 DO 中执行长时间阻塞操作。
    * (目标) 减少 DO 状态的写入频率，如果可能，可以**批量更新**状态，或只在关键节点写入。
    * 合理设计 DO ID（如基于 `taskId`）以实现负载均衡。
* **R2 存储**:
    * (目标) 对于大量对象，使用**基于哈希前缀的分层路径** (e.g., `/ab/cd/ef/image.jpg`) 避免单一目录性能瓶颈。
    * 配置合理的存储桶生命周期规则，自动清理过期或不再需要的文件。
* **Vectorize**:
    * (目标) 写入向量时，使用**批量插入** (Batch Insert)，每次**建议 50-100 条**左右，以获得较好性能。
* **D1 数据库**:
    * 为频繁查询的字段创建索引。
    * 避免大型、复杂的查询，需要时将数据预处理或反规范化。
    * 使用 Prepared Statements 防止 SQL 注入并可能提高性能。
* **代码层面**:
    * 避免在热路径上进行昂贵的计算或同步操作。
    * 谨慎使用大型依赖库，关注打包后的 Worker 体积。

**12. 安全最佳实践**

* **密钥管理**:
    * **严禁**在代码库（任何文件）、配置文件（包括 `wrangler.toml`）或日志中出现任何形式的硬编码密钥、密码、Token。
    * 所有运行时 Secrets **必须**通过 Cloudflare Secrets Store 获取，并在 `wrangler.toml` 中绑定。
    * 用于本地开发的 Secrets 存储在根目录 `.env.secrets` 文件中（**必须**加入 `.gitignore`），并通过 `tools/sync-*.sh` 脚本同步到 Cloudflare 和 GitLab CI/CD Variables。
* **输入验证**:
    * **必须**对所有来自外部的输入进行严格验证，包括：API 请求的 URL 参数、查询参数、请求头、请求体；队列消息的内容。
    * 推荐使用 **Zod** 或 Valibot 等库进行 Schema 验证。
* **权限最小化**:
    * 创建 Cloudflare API Token 时，**必须**遵循权限最小化原则，只授予执行必要操作所需的权限。
    * Worker 绑定到的 D1, R2, Queue 等服务，其访问权限也应受限（如果平台支持）。
* **依赖安全**:
    * **必须**在 CI 流程中加入依赖项漏洞扫描步骤（例如运行 `pnpm audit --prod`）。
    * (推荐) 在 CI 流程中加入 Git 仓库扫描工具（如 **Gitleaks**）防止意外提交密钥。
* **日志安全**:
    * **严禁**在日志中记录敏感信息，包括但不限于：密码、完整 API Keys/Tokens、用户个人身份信息 (PII)、JWT Tokens。必要时进行脱敏处理。
* **认证与授权**:
    * 所有面向用户的 API 端点**必须**通过 `packages/shared/auth.ts` 实现的认证机制（如 JWT 或 HMAC）进行保护。
    * 需要区分用户数据的操作，**必须**在业务逻辑中实现授权检查，确保用户只能访问其自身的数据。

**13. CI/CD 集成、校验与门禁**

* **工具链**: 使用 GitLab CI/CD。
* **流水线 (`.gitlab-ci.yml`) 阶段 (建议)**:
    1.  `lint`: 运行 `turbo run lint` (执行 ESLint 检查和 Prettier 格式检查)。
    2.  `test`: 运行 `turbo run test` (执行单元测试和集成测试)。(可选) 在此阶段加入 `pnpm audit` 和 `gitleaks` 扫描。
    3.  `build`: 运行 `turbo run build --filter=<app-name>` 构建需要部署的应用（如 `in-pages` 和各个 Worker）。
    4.  `terraform-plan`: (针对 `infra/` 目录的变更) 运行 `terraform plan`，将计划输出为 artifact。**需要手动审批 (manual approval)** 才能继续。
    5.  `deploy-staging`: (可选) 部署到 Staging 环境。包括使用 `wrangler deploy` 部署 Workers/DO，使用 `wrangler pages deploy` 部署前端。
    6.  `e2e-test`: (可选) 在 Staging 环境运行端到端测试。
    7.  `deploy-production`: (针对 `main` 分支) 部署到生产环境。
    8.  `terraform-apply`: (在 `terraform-plan` 被批准后) 运行 `terraform apply` 应用基础设施变更。
* **门禁 (Gate)**:
    * 所有 `lint`, `test`, `build` 阶段的 Job **必须**全部成功，Pull Request 才允许被合并。
    * `terraform-plan` 的 Job **必须**经过指定人员（如架构师、运维负责人）审查和手动批准后，`terraform-apply` 才能执行。
* **Terraform State**: (推荐) 将 Terraform 状态文件迁移到 **GitLab Managed Terraform State** 或其他安全的远程后端，**禁止**将状态文件提交到 Git 仓库。在 `infra/backend.tf` 中配置。
* **Secrets**: CI/CD Job 需要访问的 Secrets（如 `CLOUDFLARE_API_TOKEN`, `ACCOUNT_ID`）**必须**通过 GitLab CI/CD Variables (设置为 Protected 和 Masked) 安全地注入，而不是硬编码在 `.gitlab-ci.yml` 文件中。

**14. 文档、代码注释与版本管理**

* **代码注释 (JSDoc)**:
    * 所有导出的函数、类、接口、类型**必须**有 JSDoc 注释，清晰说明其用途、参数 (`@param`)、返回值 (`@returns`)、抛出的异常 (`@throws`)。
    * 对于内部函数或复杂的代码块，如果逻辑不直观，应添加行内注释解释“为什么”这样做，而不仅仅是“做什么”。
* **项目文档**:
    * 维护 `README.md` 提供项目概览、设置和运行指南。
    * 所有重要的设计文档、架构图、研究报告、手册等应整理存放在 `docs/` 目录下。
    * (推荐) 使用 **Architecture Decision Records (ADRs)** 格式（例如在 `docs/adr/` 目录下创建 `ADR-xxxx-decision-title.md`）记录重要的架构决策及其背景、权衡和后果。
* **变更日志 (CHANGELOG)**:
    * **必须**维护根目录下的 `CHANGELOG.md` 文件。
    * 遵循 [Keep a Changelog](https://keepachangelog.com/) 规范，记录每个版本（或重要提交批次）的新增功能 (`Added`)、变更 (`Changed`)、弃用 (`Deprecated`)、移除 (`Removed`)、修复 (`Fixed`)、安全更新 (`Security`)。
* **版本管理**:
    * 遵循语义化版本控制 (Semantic Versioning - SemVer, `vx.y.z`)。
    * 每次向生产环境发布重要更新时，应在 `main` 分支上打上对应的 **GitLab Tag** (例如 `v1.0.0`, `v1.1.0`)。
    * (推荐) 配合 GitLab Tag 创建 **GitLab Release Notes**，关联对应的 Tag 和 `CHANGELOG.md` 中的变更条目。

**15. Pull Request (PR) 与代码审查流程**

* **分支模型**: 遵循 `docs/git-branch-management.md` 中定义的 Git 分支管理规范 (如 Gitflow 简化版: `main`, `develop`, `feature/xxx`, `hotfix/xxx`)。
* **开发流程**:
    1.  从 `develop` 分支创建 `feature/<topic>` 分支进行开发。
    2.  在本地频繁提交，并确保通过本地检查 (`pnpm lint`, `pnpm test`)。
    3.  开发完成后，将 `develop` 分支的最新更改合并（`merge` 或 `rebase`）到自己的 feature 分支，解决冲突。
    4.  Push feature 分支到 GitLab。
    5.  创建 Pull Request (或 GitLab 的 Merge Request)，目标分支通常是 `develop`。
* **PR 要求**:
    * **标题**: 清晰简洁，概括主要变更。
    * **描述**: **必须**包含变更的背景（What & Why）和实现方式（How）。关联相关的 Issue (如果使用 GitLab Issues)。
    * **小而专注**: PR 应尽可能小，只包含一个逻辑单元或功能的变更，便于审查。
    * **CI 通过**: 提交 PR 后，GitLab CI 流水线（至少 `lint` 和 `test` 阶段）**必须**成功通过。
* **代码审查 (Code Review)**:
    * 每个 PR **必须**至少有 **1 位** 其他项目成员进行审查并 **Approve**。
    * 审查者关注代码质量、逻辑正确性、是否遵循规范、测试覆盖率、安全性等方面。提出建设性意见。
    * PR 作者需根据审查意见进行修改和讨论，直至获得批准。
* **合并**:
    * 获得足够 Approve 且 CI 通过后，由具有合并权限的成员（或 PR 作者，取决于项目设置）将 PR 合并到目标分支（如 `develop`）。
    * **推荐**使用 **Squash and Merge** 方式合并，保持目标分支（`develop`, `main`）的提交历史干净、线性。合并提交信息应清晰概括该 PR 的内容。
* **部署**: `main` 分支的合并通常会触发生产环境部署（如果 CI/CD 配置如此）。`develop` 分支的合并可能触发 Staging 环境部署。

**16. 参考资源**

* (添加项目相关的 Cloudflare, TypeScript, Vitest, Terraform, GitLab CI/CD 等官方文档链接)
* [Keep a Changelog](https://keepachangelog.com/)
* [Semantic Versioning](https://semver.org/)
* (可选) [12 Factor App](https://12factor.net/)
* (可选) 相关技术博客或书籍

---
**修订流程**: 本文档作为项目核心规范，任何修订建议都应通过 Pull Request 提交，经过团队讨论和批准后合并更新，并通知所有项目成员。