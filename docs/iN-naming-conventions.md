好的，我已经根据您的要求，并结合我们之前讨论过的 iN 项目细节（如强调函数式编程、异步任务处理等），对这份 **iN 项目命名规范总览** 文档进行了改进。

主要修订内容包括：

1. **添加了文档版本和日期。**  
2. **在“项目代码内部命名规范”部分（第 4 节）显著增加了对函数式编程 (FP) 的要求和指导。**  
3. **在“项目代码目录结构命名规范”部分（第 2 节）补充说明了逻辑分离的建议。**  
4. **在“Markdown 文档命名规范”部分（第 9 节）增加了实施手册的命名建议。**  
5. **为各主要章节添加了简短的引导性说明，提升可读性。**  
6. **对一些描述性文字进行了微调，使其更贴合项目实践。**

以下是修订后的文档：

---

**📘 iN 项目命名规范总览 (V1.1)**

**更新日期:** 2025-04-11

本规范文档旨在统一 iN 项目的各类命名规则，覆盖基础设施、代码、分支、文档等方面，以确保项目具备高度的一致性、可读性和可维护性，并支撑项目所采用的架构原则（如模块化、异步处理、函数式编程推荐）。

---

**🧱 1\. 基础设施资源命名规则**

本节规定了 Cloudflare 基础设施资源的命名格式，以保证资源标识的清晰和 Terraform 管理的便捷性。

| 类型 | 命名规则格式 | 示例 | 说明 |
| :---- | :---- | :---- | :---- |
| Worker | iN-worker-\[顺序字母\]-\[功能\]-\[日期\] | iN-worker-A-api-gateway-20250402 | 顺序字母建议反映部署或依赖优先级 |
| Queue | iN-queue-\[顺序字母\]-\[功能\]-\[日期\] | iN-queue-A-imagedownload-20250402 | 包括对应的 DLQ (通常用相邻字母或加 \-dlq 后缀，需统一) |
| Durable Object | iN-do-\[顺序字母\]-\[功能\]-\[日期\] | iN-do-A-task-coordinator-20250402 |  |
| R2 | iN-r2-\[顺序字母\]-\[功能\]-\[日期\] | iN-r2-A-bucket-20250402 |  |
| D1 | iN-d1-\[顺序字母\]-\[功能\]-\[日期\] | iN-d1-A-database-20250402 |  |
| Vectorize | iN-vectorize-\[顺序字母\]-\[功能\]-\[日期\] | iN-vectorize-A-index-20250402 |  |
| Pages | in-pages (固定名称，全小写) | in-pages |  |
| Logpush | iN-logpush-\[顺序字母\]-\[目标平台\]-\[日期\] | iN-logpush-A-axiom-20250402 |  |

**说明:**

* \[顺序字母\] (A, B, C...) 主要用于区分同类型资源，建议按部署或逻辑依赖顺序排列。  
* \[功能\] 应使用 kebab-case 描述资源核心职责。  
* \[日期\] 建议统一使用项目启动或该批资源决策的关键日期，如 20250402，保持不变。  
* 对于 DLQ，建议采用明确的方式，如 iN-queue-B-imagedownload-dlq-20250402，或与主 Queue 字母相邻。需在项目内保持一致。

---

**🗂️ 2\. 项目代码目录结构命名规范**

本节规范了 Monorepo 内的代码组织方式，旨在实现关注点分离和清晰的模块划分。

**2.1 apps/ 目录 (可部署应用)**

Bash

apps/  
├── in-pages/                     \# 前端应用 (与 Pages 资源名对应)  
├── iN-worker-A-api-gateway-20250402/ \# Worker 应用 (目录名与资源名完全一致)  
├── iN-worker-B-user-api-20250402/  
├── iN-do-A-task-coordinator-20250402/ \# DO 实现代码 (建议与绑定资源名一致)  
├── ...

**说明:**

* apps/ 下的目录名应与其对应的 Cloudflare **部署单元**（Worker, Pages, DO 实现）的资源名严格一致，以方便查找和 CI/CD 配置。  
* 每个子目录是一个独立的可部署单元，包含自己的 package.json 和构建配置。  
* **Worker 和 DO 目录内应主要处理副作用（如绑定调用、环境交互）和业务流程编排，并将纯粹的业务逻辑委托给 packages/ 中的共享库。**

**2.2 packages/ 目录 (共享库与逻辑)**

Bash

packages/  
├── shared/                    \# 通用工具库 (日志, 追踪, 认证, 任务状态封装等)  
├── worker-logic/              \# (推荐模式) 可复用的纯业务逻辑 (按领域划分)  
│   ├── image-processing-logic/  
│   ├── task-management-logic/  
│   └── ...  
├── types/                     \# 全局共享类型定义  
├── ui-components/             \# (若有) 共享前端 UI 组件  
├── typescript-config/         \# 共享 TS 配置  
├── eslint-config/             \# 共享 ESLint 配置

**说明:**

* 所有目录名使用 kebab-case。  
* shared/ 存放项目范围内的通用底层工具。  
* **worker-logic/ (或类似名称) 下的包，应专注于包含可测试、可复用的纯业务逻辑，尽量减少对 Cloudflare 环境或绑定的直接依赖。这有助于实践函数式编程和提高代码质量。**  
* types/ 存放跨 Worker 和共享库的 TypeScript 类型定义。

---

**🧾 3\. Terraform 文件命名规范**

本节规范了 Terraform 配置文件的组织，以匹配基础设施资源并方便管理。

Bash

infra/  
├── main.tf                     \# 提供者配置, 后端配置等  
├── variables.tf                \# 变量定义  
├── outputs.tf                  \# 输出定义  
├── modules/                    \# (可选) Terraform 模块  
├── resources/                  \# 按资源类型组织的具体定义文件  
│   ├── workers/  
│   │   ├── iN-worker-A-api-gateway-20250402.tf  
│   │   └── ...  
│   ├── queues/  
│   │   ├── iN-queue-A-imagedownload-20250402.tf  
│   │   └── ...  
│   ├── durable-objects/  
│   │   ├── iN-do-A-task-coordinator-20250402.tf  
│   │   └── ...  
│   ├── storage/  
│   │   ├── r2.tf  
│   │   ├── d1.tf  
│   │   └── vectorize.tf  
│   ├── pages/  
│   │   └── in-pages.tf  
│   └── others/                 \# 其他资源如 Logpush 等

**说明:**

* Terraform **资源定义文件名**应与其管理的**主要资源名称**保持一致 (例如 iN-worker-A-api-gateway-20250402.tf)，便于快速定位和理解文件内容。  
* 建议在 resources/ (或类似名称) 目录下按**资源类型**创建子目录（workers, queues, storage 等）来组织文件。

---

**🧬 4\. 项目代码内部命名规范**

本节规范代码内部元素的命名，以提升可读性、可维护性，并**鼓励遵循函数式编程 (FP) 原则**。

**4.1 命名风格总览**

| 类型 | 命名风格 | 示例 | 说明 |
| :---- | :---- | :---- | :---- |
| 变量名 | camelCase | taskId, userConfig, imageData |  |
| 常量 | UPPER\_CASE | MAX\_RETRIES, DEFAULT\_TIMEOUT\_MS | 通常用于模块顶层或全局配置 |
| 函数/方法名 | camelCase | getUserById, calculateSimilarity | 见下方函数式编程指导 |
| 文件名 | kebab-case | task-queue.utils.ts, image-metadata.service.ts | 反映文件内容或职责 |
| 模块/目录名 | kebab-case | shared-utilities, api-handlers | (与 packages 目录规范一致) |
| 类型/接口名 | PascalCase | ImageMetadata, TaskState, IRequestLogger |  |
| 类名 (若使用) | PascalCase | TaskCoordinatorDO (对于 DO 类) |  |
| 枚举名 | PascalCase | LogLevel, TaskStatus |  |
| 枚举成员 | UPPER\_CASE | LogLevel.INFO, TaskStatus.COMPLETED |  |

**4.2 函数式编程 (FP) 命名指导**

* **纯函数 (Pure Functions):**  
  * 应清晰表达其**转换或计算**操作，通常使用**动词或动词短语**。  
  * 命名应**不暗示副作用**。  
  * 示例: calculateTotals(items), parseImageUrl(url), validateInput(data)。  
* **执行副作用的函数 (Effectful Functions):**  
  * 必须明确标识执行 I/O 操作、状态变更（如写入 D1/DO, 推送 Queue）、或与外部系统交互的函数。  
  * 命名可包含**表明副作用的动词**，或通过模块/文件组织体现其作用性质。  
  * **强烈建议将副作用操作隔离**到特定的函数、模块或 apps/ 目录下的 Worker 代码中。  
  * 示例: saveUserToDB(user), updateTaskStateInDO(taskId, state), pushToDownloadQueue(message), WorkspaceExternalData(url).  
* **高阶函数 (Higher-Order Functions):**  
  * 命名应反映其行为，如创建新函数或操作其他函数。  
  * 示例: withRetryLogic(fn), createAuthMiddleware(options).  
* **柯里化函数 (Curried Functions) (若使用):**  
  * 命名应清晰，并通过 JSDoc/TSDoc 注释说明其参数应用顺序。

**4.3 通用说明:**

* **清晰性优先:** 避免使用模糊或过于简短的缩写。命名应自解释。  
* **一致性:** 在整个项目中保持命名风格统一。  
* **日志关联:** 所有执行日志记录的操作，其日志输出**必须**包含 traceId 和相关的 taskId (如果适用)，以便于链路追踪。 (参考第 7 节)

---

**🔁 5\. Git 分支命名规范**

本节为 Git 分支提供命名建议，以方便团队协作和版本管理。

| 类型 | 格式示例 |
| :---- | :---- |
| Feature | feature/\[模块\]-\[简短描述\] |
| Fix | fix/\[模块\]-\[bug简述\] |
| Refactor | refactor/\[模块\]-\[重构内容\] |
| Chore | chore/\[任务类型\]-\[描述\] |
| Release | release/\[版本号\] (如 v1.2.0) |
| Hotfix | hotfix/\[版本号\]-\[紧急修复内容\] |

**示例:**

Bash

feature/ai-vector-search  
fix/config-traceid-missing  
refactor/auth-jwt-validation  
chore/deps-update-turborepo  
release/v1.2.0  
hotfix/v1.2.1-do-state-race-condition

---

**🧰 6\. CI/CD Workflow 文件命名规范**

本节规范 CI/CD (如 GitHub Actions) 的 Workflow 文件命名。

Bash

.github/workflows/  
├── lint-and-test.yml      \# 代码检查与单元/集成测试  
├── terraform-plan.yml     \# Terraform Plan  
├── terraform-apply.yml    \# Terraform Apply (可能需要手动触发或审批)  
├── deploy-workers.yml     \# 部署所有或特定 Workers  
├── deploy-pages.yml       \# 部署 Cloudflare Pages  
├── release.yml            \# 创建 Release 版本

**说明:**

* 文件名应清晰反映 Workflow 的主要目的。  
* 复杂的部署可拆分为多个文件 (如按 Worker 或环境)。  
* 涉及 Terraform apply 的 Workflow 应有明确的触发机制或审批环节。

---

**📜 7\. 日志与追踪字段命名规范**

本节定义了结构化日志中的关键字段及其含义，以确保可观测性数据的一致性。

| 字段名 | 描述 | 来源/负责模块 (示例) |
| :---- | :---- | :---- |
| traceId | 贯穿请求或任务处理流程的唯一追踪标识 | shared/trace.ts |
| taskId | (若适用) 当前处理的核心业务任务的唯一 ID | 业务逻辑/DO |
| level | 日志级别: debug, info, warn, error | shared/logger.ts |
| timestamp | 日志记录发生的精确时间 (ISO 8601 格式) | shared/logger.ts |
| worker | 产生该日志的 Worker 或 DO 的名称 | shared/logger.ts |
| message | 日志主体信息 | 调用处 |
| details | (可选) 包含额外上下文信息的对象 | 调用处 |
| error | (若为错误日志) 包含错误信息的对象 (message, stack) | shared/logger.ts |

---

**🔑 8\. Cloudflare Secrets 命名规范**

本节规定了存储在 Cloudflare Secrets Store 中的密钥命名格式。

**格式:**

CF\_SECRET\_IN\_\[用途/服务\]\_\[具体描述\]\_KEY

**示例:**

CF\_SECRET\_IN\_AUTH\_HMAC\_KEY         \# 用于 API Gateway HMAC 认证的密钥  
CF\_SECRET\_IN\_AI\_SERVICE\_API\_KEY    \# 访问外部 AI 服务的 API Key  
CF\_SECRET\_IN\_VECTORIZE\_API\_TOKEN   \# 访问 Vectorize 的 API Token

**说明:**

* 使用大写字母和下划线。  
* \[用途/服务\] 指明密钥关联的服务或功能模块。  
* \[具体描述\] 提供更详细的密钥用途说明。  
* 以 \_KEY 或 \_TOKEN 或 \_SECRET 等明确类型结尾。

---

**📝 9\. Markdown 文档命名规范**

本节规范项目相关 Markdown 文档的文件命名。

| 类型 | 文件名示例 |
| :---- | :---- |
| 架构总览文档 | architecture-overview.md |
| 命名规范文档 | iN-naming-conventions.md |
| **实施步骤/指南文档** | iN-implementation-guide.md |
| 未来规划/路线图文档 | iN-future-modernization.md |
| 资源清单与职责 | iN-resources-and-duties.md |
| 特定 Worker 设计文档 | worker-design-\[模块名\].md |
| 决策记录文档 | adr-\[编号\]-\[简述\].md |
| 规范变更历史 | iN-naming-conventions-history.md |

**说明:**

* 文件名使用 kebab-case。  
* 文件名前缀 iN- 用于项目特定文档，通用文档（如 architecture-overview.md）可不加。  
* 如需记录规范的变更历史，建议创建 \*-history.md 文件。

---

