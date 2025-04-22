# 🌟 action-checklist-20250422.md
_当前阶段 iN 项目任务收敛清单_

## ✅ 核心目标：完成 MVP、打通主链、可视化展示

### 📦 架构 & 基础设施
- [x] 完成 Terraform 管理所有资源（Queue, DO, D1, R2, Pages）
- [x] 实现 Durable Object 状态机（TaskCoordinator）
- [x] 配置 wrangler.toml 和 secrets 管理脚本

### ⚙️ 核心任务链
- [ ] 完成下载 Worker（iN-worker-D-download）
- [ ] 完成元数据 Worker（iN-worker-E-metadata）
- [ ] 完成 AI Worker（iN-worker-F-ai）
- [ ] 实现任务状态变更流程（通过 DO）
- [ ] 确保每个阶段 Worker 的幂等性逻辑

### 📡 API 层建设
- [x] 初始化 API Gateway Worker
- [ ] 实现任务触发与查询 API（config-api / query-api）
- [ ] 加入认证逻辑（HMAC/JWT）

### 💻 前端整合
- [ ] 完成任务触发 UI（配置界面）
- [ ] 实现结果查询界面（状态列表 / AI 输出）
- [ ] 联调 API，打通端到端流程

### 🔍 可观测性与健壮性
- [ ] 启用 Logpush 到 Axiom
- [ ] 定义日志字段规范 + traceId
- [ ] 实现 DLQ 基础处理逻辑（MVP）

---
文件名：action-checklist-20250422.md  
生成时间：20250422
# 🏗️ architecture-summary-20250422.md

iN 项目采用现代分布式异步架构，基于 Cloudflare 栈为核心，并辅以 Vercel 和 Firebase 提供边缘展示与认证服务，架构设计体现 Serverless、事件驱动、状态协调、可观测性等现代范式。

## ✅ 架构关键特性

- **异步队列驱动主链流程**：图片下载 → 元数据 → AI 处理由 Cloudflare Queues 驱动，严格解耦。
- **状态管理采用 Durable Object（DO）**：每个任务绑定一个 DO 实例，支持状态幂等更新与可追踪。
- **可观测性链路完整**：TraceID 全程贯穿，Logpush 推送至 Axiom，提供实时监控。
- **结构化项目管理**：Monorepo + Turborepo 管理前后端、Worker、Infra 与共享库。
- **安全体系分层清晰**：用户层采用 Firebase Auth，内部服务使用 HMAC/JWT 签名校验。

## ✅ 核心架构构件

| 层级 | 技术 | 职责 |
|------|------|------|
| 前端展示 | Vercel + Cloudflare Pages | 配置输入、任务查看、搜索查询 |
| API 层 | Workers A/B/G/H/I/J | 网关 + 任务配置 + 数据查询接口 |
| 核心流程 | Workers C/D/E/F + DO + Queues | 图片处理主流程 |
| 存储层 | R2, D1, Vectorize | 原图 + 元数据 + 向量数据存储 |
| 状态协调 | TaskCoordinatorDO | 任务状态状态机 |
| 日志链路 | logger.ts + trace.ts + Axiom | 可追踪结构化日志 |

---

文档名：architecture-summary-20250422.md  
更新日期：2025-04-22
# 📊 axiom-dashboard-notes-20250422.md
_日志与指标接入 Axiom 的实战指南_

## ✅ Logpush 设置

- 所有 Worker 需启用 `logpush = true`
- 日志字段要求结构化（JSON 格式）：
```json
{
  "timestamp": "...",
  "traceId": "...",
  "taskId": "...",
  "worker": "download",
  "message": "Downloaded image",
  "level": "info"
}
```

## 📈 推荐指标

- 队列处理时间（Queue Lag）
- 每个 Worker 的错误率
- DLQ 长度变化趋势
- API 请求耗时（可打入日志）
- 任务完成率

## 🧩 仪表盘结构建议

| 面板 | 内容 |
|------|------|
| 概览 | 任务总数、失败数、平均耗时 |
| 下载 | 下载错误率、图片大小分布 |
| AI | 分析耗时、常见标签 |
| DLQ | 死信队列趋势图 |
| traceId | 支持按 traceId 跟踪完整链路 |

---

文件名：axiom-dashboard-notes-20250422.md  
生成时间：20250422
# 🧭 iN 项目最佳实践手册  
📄 文档名称：best-practices-20250422.md  
🗓️ 更新时间：2025-04-22

---

## 📦 架构分层最佳实践

- 使用 Cloudflare Workers 拆分任务与 API 层职责（apps/* 分层）
- Durable Object 用于状态强一致管理，禁止状态漂移
- 所有副作用逻辑抽出封装为共享库（packages/shared-libs/*）
- 所有任务流由 Queue 驱动，Worker 消费逻辑保持幂等性
- 所有 API 接口前置 Gateway Worker 做统一认证与路由

---

## 🔐 安全最佳实践

- 所有敏感配置通过 `.env.secrets` 管理，并同步至 GitLab/Cloudflare
- Firebase Auth 用于用户层面认证，HMAC 用于服务间签名验证
- 日志中禁止输出 token、key、cookie 等信息
- 所有接口需做签名验证或身份校验，接入前强制使用 `auth.ts`

---

## 🧩 前端开发最佳实践

- 使用 SvelteKit 构建 SPA，部署于 Vercel，配置支持 ENV 区分环境
- 所有 API 调用封装统一客户端并处理错误与 token 注入
- 尽量使用公共组件与 tailwind 统一 UI 样式
- 用户配置页面与状态列表页面分离，便于维护

---

## 🧪 测试与 CI 最佳实践

- 所有共享逻辑须编写 Vitest 单测，确保纯函数覆盖率
- Worker 需本地 wrangler dev + traceId 联调日志观察
- GitLab CI 检查 Lint、Test、Build、Terraform Plan
- 推送至主分支必须通过 GitLab 合并请求审查

---

## 📈 可观测性最佳实践

- 所有日志统一通过 `logger.ts` 输出，格式化为 JSON 并带 traceId
- Logpush 推送日志至 Axiom，结合仪表盘实现监控
- 所有 Worker 和 API 请求附加 traceId Header 以追踪链路
# 🌿 Git 分支策略规范  
📄 文档名称：branch-strategy-20250422.md  
🗓️ 更新时间：2025-04-22  

---

## 📁 主分支定义

| 分支名 | 用途 | 自动部署 |
|--------|------|------------|
| `main` | 主生产分支，受保护，仅合并变更 | ✅ Vercel Production |
| `dev`  | 主开发分支，日常开发合并 | ✅ Vercel Preview |
| `hotfix/*` | 紧急修复分支 | ✅ 手动合并触发部署 |
| `feature/*` | 新功能开发临时分支 | ❌ 不自动部署 |
| `docs/*` | 文档维护分支 | ❌ |

---

## 🧪 流程建议

- 所有功能应由 `feature/*` 派生并通过 MR 合并至 `dev`
- 阶段性版本开发完成后，从 `dev` 合并至 `main`
- `main` 分支必须通过 GitLab 审查并验证 CI/CD 成功
- 发布版本建议打 Tag：如 `v0.1.0`

---

## 🔁 与 Vercel 配合

- `dev` 分支自动绑定 Vercel Preview 环境
- `main` 分支绑定 Vercel 正式环境
- 环境变量通过 `VERCEL_ENV` 自动识别：`development` / `preview` / `production`
# 📄 ci-structure-20250422.md
📅 Updated: 2025-04-22

## 当前 CI/CD 概况

- 使用 GitLab CI
- 阶段划分：Lint → Test → Build → Deploy → Terraform Apply（未来计划）
- 项目采用 Monorepo 结构，CI 结合 Turborepo 执行子任务调度

## 协作预留建议（未来）

- 引入分支保护策略：main/dev 禁止直接 push，需通过 MR 审查
- 设定 Reviewer 审批逻辑（如至少 1 人 Review 才允许合并）
- 集成 Secrets 检查、依赖扫描、Terraform Plan 自动审批
# 🧑‍💻 编码与风格规范  
📄 文档名称：coding-guidelines-20250422.md  
🗓️ 更新时间：2025-04-22  

---

## 🧱 通用规则

- 使用 TypeScript 编写所有业务逻辑
- 遵循函数式编程风格：纯函数、不可变、组合优先
- 所有模块需模块化拆分，副作用需封装进共享库

---

## 🌐 Cloudflare Worker 编码规范

- 每个 Worker 独立部署、独立 wrangler.toml、命名规范一致
- 所有 Worker 必须使用 `logger.ts`, `trace.ts`, `auth.ts`
- 所有 queue 消费逻辑必须幂等
- 所有状态操作走 `task.ts` 提供的接口，不允许绕过 DO

---

## 🎨 前端（Vercel + SvelteKit）

- 前端页面按 route 结构划分，统一使用 Layout 组件
- 所有 API 请求封装至 `lib/api.ts`，统一注入 Auth Token 与错误处理
- Tailwind 用于样式定义，禁止内联样式
- 禁止将密钥、地址硬编码进页面，全部使用 PUBLIC_ 环境变量导入

---

## 🔐 安全与验证

- 所有接口入参使用 Zod 校验器验证类型与范围
- 所有敏感数据使用 Secrets Store 管理，禁止出现在源码中
- 日志输出需结构化且禁用敏感字段打印
# ☑️ dlq-handling-guide-20250422.md
_DLQ（Dead Letter Queue）自动处理机制设计指南_

## 🧩 背景

DLQ 是处理失败队列中无法重试的消息，保障主链稳定运行的重要组件。

## ✅ 建议机制

1. 所有 DLQ 均绑定日志增强 Worker 或记录系统
2. 持续轮询队列消息（可设置间隔触发）
3. 失败原因记录后分类：
   - 可重试：重新推入主队列（最多 3 次）
   - 不可重试：记录日志 + 告警 + 丢弃
   - 待人工分析：持久化到 KV/R2 中，供后续审计

## 🔁 示例脚本（伪代码）

```ts
while (true) {
  const msg = await dequeue(DLQ);
  if (shouldRetry(msg)) {
    enqueue(MainQueue, msg);
  } else {
    logToAxiom(msg);
  }
}
```

---
文件名：dlq-handling-guide-20250422.md
生成时间：20250422
# 🧠 iN 工程实践说明  
📄 文档名称：engineering-practices-20250422.md  
🗓️ 更新时间：2025-04-22  

---

## ✅ 工程结构设计

- 使用 Monorepo 管理：前端、后端 Worker、共享库、IaC、工具脚本集中管理
- 使用 pnpm + turborepo 实现依赖追踪与缓存优化
- 所有应用（apps/）与库（packages/）严格职责分离
- 基于 wrangler.toml 与 terraform 实现完整资源与服务配置统一

---

## 🧪 开发与测试流程

- 单元测试：Vitest 用于所有函数逻辑测试
- 集成测试：wrangler dev + curl/Postman 本地调试接口与 DO 行为
- CI 流程：通过 GitLab 执行 lint → test → build → terraform plan → deploy

---

## 🛡️ 安全与认证实践

- 接口级：所有请求必须通过 JWT/HMAC 验证
- 用户级：使用 Firebase Auth 实现 OAuth 登录（Google/GitHub）
- 配置级：所有密钥集中存储，禁止硬编码，使用 Secrets Store 管理
- Worker 层级隔离：下载、元数据、AI、API 均拆分 Worker，权限最小化

---

## 🔁 架构演进与插件机制

- 主链稳定后可引入事件队列（Pub/Sub）拓展通知与索引等旁路逻辑
- Vectorize 与 Logpush 接入支持图像搜索与日志分析
- 后续引入 Feature Flags、Canary 发布机制优化部署体验
# 🧩 event-example-log-subscriber-20250422.md
_事件驱动架构示例订阅者：日志增强 Worker_

## 🎯 目标

作为事件驱动架构 MVP 的第一订阅者，`log-enhancer-worker` 用于消费任务链事件并生成更丰富的日志记录。

## 🧱 架构角色

- 订阅队列：ImageEventsQueue
- 消费事件：如 `image.downloaded`, `metadata.extracted`, `ai.analyzed`
- 输出增强日志：包含阶段状态、处理时间、traceId、taskId 等

## 🧪 示例事件格式（from shared-libs/events/）

```ts
type INEvent<T extends string, P = unknown> = {
  type: T;
  timestamp: number;
  traceId: string;
  taskId: string;
  payload: P;
};
```

## 🚀 示例逻辑（伪代码）

```ts
onQueueMessage(event) {
  logToAxiom({
    traceId: event.traceId,
    taskId: event.taskId,
    stage: event.type,
    ...event.payload
  });
}
```

---

文件名：event-example-log-subscriber-20250422.md  
生成时间：20250422
# 📄 event-schema-spec-20250422.md
📅 Updated: 2025-04-22

## 核心事件接口设计：INEvent<T>

```ts
interface INEvent<T> {
  type: string; // 事件类型，如 image.downloaded
  timestamp: number;
  taskId: string;
  traceId?: string;
  payload: T;
}
```

## 示例：image.downloaded

```json
{
  "type": "image.downloaded",
  "timestamp": 1713770000000,
  "taskId": "task-abc123",
  "traceId": "trace-xyz987",
  "payload": {
    "imageKey": "bucket/abc.jpg",
    "source": "unsplash",
    "size": 3822991
  }
}
```

## 使用建议

- 事件结构统一由共享库生成，发送方和接收方依赖同一类型定义
- 所有订阅端需实现幂等处理
# 🔁 frontend-integration-guide-20250422.md
_向量搜索联调说明 + API 对接建议_

## 🌉 前后端联通目标

- 支持用户在前端页面发起图片查询请求
- 显示查询结果，包括 AI 分析标签、相似图片等

## ✅ API 接口

- 查询接口：`/api/image/search`
- 参数结构：
```json
{
  "query": "dog",
  "limit": 10
}
```

## 🔍 搜索类型

- 基于文本描述（调用 Vectorize + 向量索引）
- 基于相似图片（后续支持）

## 💡 联调建议

- 使用 `POST` 请求发送 query，封装成 form
- 确保传递 `traceId` 用于日志追踪
- 接口返回结构包括：
```json
{
  "results": [
    {
      "imageUrl": "...",
      "score": 0.97,
      "tags": ["dog", "animal"]
    }
  ]
}
```

## 🎨 页面建议

- 输入框 + 查询按钮
- 查询结果展示网格
- 支持 loading 状态与空结果处理

---

文件名：frontend-integration-guide-20250422.md  
生成时间：20250422
# 📄 frontend-pages-map-20250422.md
📅 Updated: 2025-04-22

## 当前页面结构规划

| 页面路径 | 功能              | 是否 MVP 目标 |
|----------|-------------------|----------------|
| `/`      | 状态查询展示页    | ✅ 是          |
| `/config`| 配置编辑页        | ✅ 是          |
| `/search`| 向量搜索界面      | ✅ 是          |

## 限制说明

- 总体页面数建议限制在 3 个以内，便于逻辑集中与资源聚焦
- 每个页面建议组件不超过 3 层嵌套
# 🚧 future-roadmap-20250422.md

## 📍 收敛式演进路线图

本项目为单人架构实验项目，核心目标是实践现代工程范式与关键能力落地，非商业化系统。

在已有架构基础上，后续仅推进以下少量高价值收敛性演进：

---

## 🧠 向量搜索（Vectorize）

- 实现向量向量化结果存储至 Cloudflare Vectorize。
- 提供基本文本向量查询 API 与前端界面。

## 📊 状态展示

- 增加图片任务状态 API（调用 DO）
- 前端展示任务状态流程（包括当前进度、失败提示）

## ☑️ DLQ 自动重试机制

- 对三条主链 DLQ 引入定时重试脚本（Worker + alarm）
- 并配置监控 / 警报机制

## 🧩 日志增强订阅者（事件驱动）

- 启动 log-enhancer Worker 消费 ImageEventsQueue
- 发布更详细日志与事件流指标（写入 Axiom）

---

文档名：future-roadmap-20250422.md  
更新日期：2025-04-22
# 🧹 Git 历史敏感信息清理记录（git filter-repo + Gitleaks）

本项目已完成一次完整的 Git 历史敏感信息清理操作，以下为操作过程记录和安全措施回顾。
2025年4月18日

---

## ✅ 问题起因

在 Git 历史记录中发现以下敏感信息泄露：

- `infra/terraform.tfvars` 中包含 `cloudflare_api_token`
- `infra/.terraform/terraform.tfstate` 中包含 `gitlab personal access token (PAT)`

通过 [Gitleaks](https://github.com/gitleaks/gitleaks) 自动集成于 CI 检测出：

```bash
gitleaks detect --report-format sarif --report-path gitleaks-report.sarif
```

---

## 🛠 清理操作步骤（Git 历史重写）

### 1. 克隆干净仓库副本用于操作

```bash
git clone git@gitlab.com:79/in.git in-clean
cd in-clean
```

### 2. 使用 git-filter-repo 移除历史中的敏感文件

```bash
git filter-repo --path infra/terraform.tfvars --invert-paths
git filter-repo --path infra/.terraform/terraform.tfstate --invert-paths
```

> 注意：每次运行 `git filter-repo` 会清除历史中该文件的所有版本，并移除 remote。

### 3. 恢复远程 origin 并强制推送覆盖旧历史

```bash
git remote add origin git@gitlab.com:79/in.git
git push origin --force --all
```

> ⚠️ 强推后，其他协作者需要重新克隆仓库

---

## ✅ 成功验证标准

- Gitleaks 在 CI 中报告 `leaks found: 0`
- `.git` 中找不到任何 tfvars、.tfstate、Token 内容
- `.gitignore` 配置已屏蔽该类文件防止再次提交

---

## 🧩 后续建议

- 启用 Terraform Remote Backend，避免 tfstate 本地文件化
- 所有 Secrets 使用 `.env.secrets` 管理 + 不提交
- GitLab CI/CD 中改为使用变量形式，如 `TF_VAR_cloudflare_api_token`
# 🔄 混合事件驱动架构说明  
📄 文档名称：hybrid-event-driven-20250422.md  
🗓️ 更新时间：2025-04-22  

---

## 📦 架构背景

iN 项目为异步图像处理系统，流程包括：
- 下载图片 → 元数据提取 → AI 分析 → 存储 → 查询展示

其中需要：
- 主链控制流程一致性
- 副作用任务（如日志、索引）异步解耦

---

## 🎯 架构原则

> 主链使用 Task Queue + DO 控制严格流程  
> 旁路副作用使用 Event Queue 发布广播 → 订阅者异步消费

---

## 🧱 实际实现结构

| 层级 | 机制 | 描述 |
|------|------|------|
| 主任务流程 | Queue + Durable Object | 状态机控制下载 → 元数据 → AI |
| 事件发布 | Worker 内部发出事件（如 `image.downloaded`） | 使用 `INEvent<T>` 结构 |
| 事件订阅 | 可选 Worker 订阅事件队列（如 `log-worker`） | 实现异步副作用 |
| 事件接口 | `shared-libs/events/` | 所有事件统一定义结构 |
| 幂等与重试 | 所有消费者实现幂等处理 | 支持重复交付、支持 DLQ |

---

## 🧩 插件系统简化说明

- 插件 Worker 仅为示范用途：如 `log-enhancer-worker`
- 插件不具备注册中心、生命周期感知
- 插件发布仅通过 `INEvent<T>` 广播机制触发

---

## 📘 总结

主链可控、副作用可插、整体异步、可观测，是现代事件架构实践的简化落地方案。
# 📦 iN 项目基础设施资源详解（20250420）

> 本文档详细记录 iN 项目使用的全部基础设施资源，覆盖 Cloudflare、Firebase、Vercel 三个平台。

---

## ☁️ Cloudflare 资源清单（主控系统）

| 类型 | 名称示例 | 说明 |
|------|-----------|------|
| Workers | `in-worker-a-api-gateway-20250402` 等 11 个 | 所有 API、任务处理逻辑运行在 Worker 中，按模块独立部署 |
| Durable Object | `in-do-a-task-coordinator-20250402` | 任务状态协调器，管理任务状态生命周期 |
| Queues | `in-queue-a-image-download-20250402` 等 7 个 | 异步任务主链与副作用事件链 |
| R2 Bucket | `in-r2-a-image-bucket-20250402` | 图像原图与中间结果文件存储 |
| D1 数据库 | `in-d1-a-database-20250402` | 结构化元数据、任务记录、用户配置 |
| KV 命名空间 | `in-kv-a-runtime-config-20250402` | 配置缓存 / 快速索引表等小型数据存储 |
| Vectorize Index | `in-vectorize-a-index-20250402` | 图像向量嵌入与相似图查询支持 |
| Secrets Store | 各 Worker 绑定专属密钥 | 包含 `RUNTIME_HMAC_SECRET`、AI 密钥等运行时密钥 |
| Logpush | `in-logpush-a-axiom-20250402` | 推送结构化日志至 Axiom 用于观测与告警 |

---

## 🔐 Firebase 资源清单（辅助用户身份与配置）

| 类型 | 名称 | 说明 |
|------|------|------|
| 项目 ID | `in-fb-core-20250420` | Firebase 主项目标识，与 Vercel / API 绑定配合 |
| Auth | Gmail / GitHub 登录启用 | 用于用户 OAuth 登录与 token 获取 |
| Firestore | `presets` / `favorites` 集合 | 用户配置存储（偏好、收藏夹、下载预设等） |
| API 密钥 | 环境变量中管理 | Firebase SDK 使用的密钥，仅在后端使用 |
| Firebase 控制台 | https://console.firebase.google.com/project/in-fb-core-20250420 | 控制台管理认证与规则设置等 |

---

## 🎨 Vercel 资源清单（前端展示平台）

| 类型 | 名称 | 说明 |
|------|------|------|
| 项目名称 | `in-vc-pages-20250420` | 前端托管项目，SvelteKit 渲染用户界面 |
| Team | 默认或个人 Team | 用于集成 GitLab 仓库并部署 Preview |
| 环境变量 | 与 GitLab 同步管理 | 包含 `API_GATEWAY_URL`, `FIREBASE_CONFIG`, `PUBLIC_SITE_ID` 等 |
| 部署分支 | `main`, `preview/*` | Vercel 自动部署分支（与 GitHub Actions 或 GitLab 配合） |
| SSR 支持 | 启用 Vercel Edge Functions（可选） | 当前采用 SSG / ISR + API 接口结合 |
| Preview 链接 | `*.vercel.app` | 各分支生成的预览地址，用于测试与迭代展示 |

---

## 📚 管理方式

- 所有 Cloudflare 资源由 Terraform 管理（位于 `infra/`）
- Firebase 项目手动初始化，配置信息记录在 `.env.secrets`
- Vercel 项目通过控制台与 GitLab 仓库绑定，配置由 `project-settings` 与 `wrangler.toml` 协同维护

---

## 🔒 安全说明

- 所有密钥均存放于 `.env.secrets` 并通过以下脚本同步：
  - `tools/sync-runtime-to-cloudflare.sh`
  - `tools/sync-to-gitlab.sh`
- Firebase API Key 仅供后端调用，前端使用的公开配置通过 ENV 注入控制暴露
- 日志与认证信息使用 `traceId`, `taskId`, `userId` 严格结构化记录

---

# iN 项目基础设施资源清单（含功能说明）

## Workers

- **iN-worker-api-gateway**: 统一 API 入口，执行请求路由、认证、traceId 注入和日志记录。
- **iN-worker-user-api**: 处理用户账户的注册、登录、查询等操作。
- **iN-worker-image-query-api**: 提供图片列表、详情和任务状态查询能力。
- **iN-worker-image-mutation-api**: 支持图片的元数据修改和逻辑删除。
- **iN-worker-image-search-api**: 执行关键词与向量相似性搜索。
- **iN-worker-config-api**: 管理用户下载配置和图片源配置。
- **iN-worker-config**: 根据配置调度任务，初始化 DO 状态，推送至下载队列。
- **iN-worker-download**: 下载原始图片写入 R2，并推进到下一处理阶段。
- **iN-worker-metadata**: 提取图片元数据并存储于 D1。
- **iN-worker-ai**: 调用 AI 服务进行图片分析与向量生成。

## Queues

- **iN-queue-imagedownload**: 传递下载图片任务。
- **iN-queue-imagedownload-dlq**: 存储下载任务失败的消息。
- **iN-queue-metadataprocessing**: 传递元数据提取任务。
- **iN-queue-metadataprocessing-dlq**: 存储元数据提取失败的任务消息。
- **iN-queue-aiprocessing**: 传递 AI 分析任务。
- **iN-queue-aiprocessing-dlq**: 存储 AI 分析失败的任务消息。

## Durable Objects

- **iN-do-task-coordinator**: 为每个任务提供状态协调与进度跟踪。

## Storage

- **iN-r2-bucket**: 存储原始图片。
- **iN-d1-database**: 存储用户、配置、图片元数据与 AI 结果。
- **iN-vectorize-index**: 用于向量存储与相似性搜索。

## Other Services

- **iN-pages**: 托管前端页面。
- **iN-logpush-axiom**: 将结构化日志推送到日志平台（如 Axiom）。

## Infra Management

- **Terraform**: 用于 Cloudflare 全部资源的 IaC 管理。
- **Secrets Store**: 管理 Cloudflare Worker 使用的敏感密钥。
- **Monorepo (pnpm + Turborepo)**: 统一管理前端、Worker 与共享代码的 Monorepo 结构。
# iN 项目基础设施资源清单（仅名称）

## 💻 Workers（共 10 个）

- `iN-worker-api-gateway`
- `iN-worker-config-api`
- `iN-worker-config`
- `iN-worker-download`
- `iN-worker-metadata`
- `iN-worker-ai`
- `iN-worker-user-api`
- `iN-worker-image-query-api`
- `iN-worker-image-mutation-api`
- `iN-worker-image-search-api`

## 📬 Queues（共 6 个，包括 DLQs）

- `iN-queue-imagedownload`
- `iN-queue-imagedownload-dlq`
- `iN-queue-metadataprocessing`
- `iN-queue-metadataprocessing-dlq`
- `iN-queue-aiprocessing`
- `iN-queue-aiprocessing-dlq`

## 🧠 Durable Object Bindings

- `iN-do-task-coordinator`

## 🗃️ Storage（共 3 个）

- `iN-r2-bucket`
- `iN-d1-database`
- `iN-vectorize-index`

## 🌐 前端与日志

- `iN-pages-frontend`
- `iN-logpush-axiom`
# 🛠 local-dev-strategy-20250422.md
_本地开发流程与模拟环境建议_

## ✅ 工具推荐
- Wrangler v4 CLI
- Vitest + tsx 本地测试执行
- Miniflare（可选）：模拟 DO / KV / D1

## ⚙️ 本地开发流程

### 1. 单 Worker 本地测试
```bash
cd apps/in-worker-D-download-20250402
wrangler dev
```
支持访问 `localhost:8787` 进行 API 测试。

### 2. 模拟 Queue 推送
使用 CURL/脚本直接 POST 消息至 dev 中监听的 `queue()`。建议写 test helper：
```ts
POST http://localhost:8787
Body: { "taskId": "...", "imageUrl": "..." }
```

### 3. Durable Object 测试
可通过绑定 Stub 模拟交互：
```ts
const id = env.TASK_COORDINATOR_DO.idFromName(taskId)
const stub = env.TASK_COORDINATOR_DO.get(id)
await stub.fetch("/status")
```

## 🧪 自动化测试建议
- 单元测试使用 Vitest + Mocks
- 集成测试推荐通过 wrangler dev 模拟队列流转

## 📝 注意事项
- 多 Worker 协同推荐 mock handler 流转测试
- 所有请求建议传递 traceId 便于后期追踪

---
文件名：local-dev-strategy-20250422.md  
生成时间：20250422
# 📊 Cloudflare Logpush 接入 Axiom 指南  
📄 文档名称：logpush-axiom-guide-20250422  
🗓️ 更新时间：20250422  

---

## 🎯 目标

通过结构化日志输出 + Cloudflare Logpush，实现 iN 项目的日志链路接入 Axiom，实现可追踪、可聚合、可告警的日志系统。

---

## 📦 步骤一：日志结构设计

使用 `packages/shared-libs/logger.ts` 统一输出格式：

```ts
{
  level: 'info' | 'warn' | 'error'
  message: string
  traceId?: string
  taskId?: string
  worker: string
  timestamp: string
  ...context // 业务上下文字段
}
```

---

## 🛠️ 步骤二：Logpush 设置

1. Terraform 中定义 logpush 配置（或控制台启用）
2. 目标类型选择：HTTPS Logpush Destination
3. Axiom 创建 Dataset + Token
4. Logpush 配置中设置 Headers（携带 Axiom Token）

---

## 🔎 步骤三：验证与可视化

- 使用 Axiom 查询 traceId 或 taskId 查看链路日志
- 配置 Dashboard：
  - Worker 执行错误率
  - 每阶段耗时
  - DLQ 消费统计
- 配置告警规则：
  - 错误率 >5%
  - 单阶段耗时异常
  - DLQ 非空

---

## ✅ 推荐策略

- 本地 logger 输出 → Logpush → Axiom
- 不需额外存储/中转，直接接入并聚合分析
- 每个 traceId 为最小观察单位
# 🚀 iN 项目 MVP 实现清单  
📄 文档名称：mvp-manifest-20250422.md  
🗓️ 更新时间：2025-04-22  

---

## 🎯 最小可行产品目标

构建一个**完整闭环的图片处理系统**，包括采集 → 分析 → 存储 → 展示，体现核心架构与工程范式。

---

## ✅ 核心功能点

| 模块 | 描述 | 状态 |
|------|------|------|
| 图片采集 | 拉取 URL，写入 R2 | ✅ Worker D |
| 元数据提取 | 获取尺寸、格式等 | ✅ Worker E |
| AI 分析 | 获取向量与标签 | ✅ Worker F |
| 状态管理 | 使用 Durable Object 管控流转状态 | ✅ DO 实现 |
| 配置接口 | 创建任务，配置参数 | ✅ Worker B |
| 查询接口 | 获取状态、图片信息 | ✅ Worker H |
| 向量搜索 | 查询相似图像 | 🔄 计划接入 |
| 前端配置页面 | 登录、配置、发起任务 | ✅ `/config` |
| 状态追踪页面 | 展示任务链与状态 | 🔄 进行中 |

---

## 🧪 测试与部署

- ✅ 所有共享库具备基本单元测试
- ✅ GitLab CI 执行 Lint/Test/Build
- ✅ Wrangler 可本地模拟 API
- ✅ Terraform Plan 校验资源同步性

---

## 📘 MVP 定义原则

> 满足以下条件即可认定为完成：
> - 核心链路完整闭环（Download → Metadata → AI）
> - 配置 + 查询功能可用
> - 前后端可用、API 可追踪
> - 部署/测试流程通顺、资源可管控
# 🏷️ 命名规范总表  
📄 文档名称：naming-conventions-20250422.md  
🗓️ 更新时间：2025-04-22  

---

## ☁️ Cloudflare 命名规范

格式：`in-<类型>-<顺序字母>-<功能名>-<日期>`

| 类型 | 示例 | 描述 |
|------|------|------|
| Worker | `in-worker-a-api-gateway-20250402` | 独立部署 Worker |
| Queue | `in-queue-b-download-20250402` | 消息队列；DLQ 用下一个字母 |
| Durable Object | `in-do-a-task-coordinator-20250402` | 状态机协调器 |
| R2 Bucket | `in-r2-a-original-images-20250402` | 原图存储桶 |
| D1 Database | `in-d1-a-metadata-20250402` | 元数据存储 |
| Vectorize Index | `in-vectorize-a-index-20250402` | 图像向量索引 |
| Logpush | `in-logpush-a-axiom-20250402` | 日志转发配置 |

---

## 🔐 Firebase 命名建议

| 项目 | 示例 | 说明 |
|------|------|------|
| Firebase Project ID | `in-firebase-202504` | 建议与主项目同名或近似 |
| Firestore Collection | `user-configs`, `presets` | 全部小写、带复数 |
| Auth Provider | `google`, `github` | OAuth 标准类型名 |

---

## 🌐 Vercel 命名建议

| 项目 | 示例 | 说明 |
|------|------|------|
| Vercel 项目名 | `in-pages` | 对应 SPA 前端项目 |
| 环境变量前缀 | `PUBLIC_CONFIG_` | 所有前端可访问变量 |
| 域名 | `in-pages.vercel.app` | 可自定义绑定 |
# 🧱 iN 分阶段实施计划  
📄 文档名称：phased-implementation-20250422.md  
🗓️ 更新时间：2025-04-22  

---

## 🎯 项目目标

以 Cloudflare 为核心平台，结合 Firebase 与 Vercel，构建一套异步、事件驱动、可观测、模块化的智能图像处理系统。  
本计划旨在引导从初始化到核心逻辑开发再到前后端集成与上线的完整实施路径。

---

## 📊 阶段概览

| 阶段 | 目标 | 涉及平台 |
|------|------|-----------|
| 阶段 0️⃣ | 项目结构初始化 + 工具链搭建 | 本地, GitLab |
| 阶段 1️⃣ | 构建核心资源 + 共享库 | Cloudflare |
| 阶段 2️⃣ | 实现任务主链逻辑 | Cloudflare |
| 阶段 3️⃣ | 构建 API 接口与认证集成 | Cloudflare + Firebase |
| 阶段 4️⃣ | 开发 SPA 前端 + 与后端集成 | Vercel + Firebase |
| 阶段 5️⃣ | 可观测性、日志告警、安全加固 | 全平台 |

---

## ✅ 阶段 0：项目初始化（1-2 天）

- 初始化 GitLab 仓库，配置 `.gitignore`, `.editorconfig`
- 配置 `pnpm + turborepo` 管理 Monorepo
- 创建目录结构：`apps/`, `packages/`, `infra/`, `tools/`, `docs/`
- 初始化 wrangler 和 terraform 项目
- 设置 Vercel 项目并连接 GitLab 仓库
- 启动 Firebase 项目（只启用 Auth 与 Firestore）

---

## ✅ 阶段 1：核心资源创建与共享库搭建（2-3 天）

- 使用 Terraform 创建：
  - R2 Bucket
  - D1 数据库（含初始 schema）
  - 任务主链队列（及 DLQ）
  - Durable Object 命名空间
  - Vectorize Index
  - Logpush 配置推送至 Axiom
- 初始化共享库（packages/shared-libs）：
  - `logger.ts`, `trace.ts`, `task.ts`, `auth.ts`
- 同步 Secrets 至 Cloudflare 与 GitLab

---

## ✅ 阶段 2：任务主链逻辑实现（5-7 天）

- 实现 Durable Object 状态机逻辑（taskId 状态流转）
- 编写队列消费者 Worker：
  - 下载（从远端拉取 → 写入 R2 → 推入元数据队列）
  - 元数据（读取 R2 → 提取元信息 → 写入 D1）
  - AI（分析并写入 Vectorize）
- 确保幂等、日志、traceID 等结构化实现
- 编写 Vitest 单测

---

## ✅ 阶段 3：API 层构建 + 身份认证接入（3-5 天）

- 构建 API Gateway Worker，实现统一入口、路由与认证
- 实现 Config API、Query API 等模块化 Worker
- 集成 Firebase Auth（通过 ID token 验证用户身份）
- 实现基础 HMAC 签名机制，支持服务间验证

---

## ✅ 阶段 4：前端 SPA 开发 + 集成（5-7 天）

- 使用 SvelteKit 搭建 Vercel 前端项目
- 实现以下页面：
  - 登录页面（对接 Firebase）
  - 配置页面（读取/保存用户 preset）
  - 状态面板页面（查询任务状态）
  - 任务详情页面（展示图片与 AI 结果）
- 环境变量配置：使用 `.env` + `vercel` 环境管理 UI 配置

---

## ✅ 阶段 5：可观测性、告警与安全加固（持续集成）

- 配置 Cloudflare Logpush 至 Axiom
- 创建 Axiom 仪表盘：队列延迟、DO 错误、任务耗时
- 接入 Secrets 管理脚本
- 审查 Firebase Firestore / Auth 权限规则
- 加入输入验证（Zod）与 API 限流策略
- 设计 DLQ 处理机制（失败任务监控与重试）

---

## 🔁 后续与可选扩展阶段

- 多租户支持（按 tenantId 设计表结构与索引隔离）
- 向量搜索页面（对接 Vectorize 实现图像推荐）
- 插件机制（事件发布 + Worker 订阅扩展）
- 蓝绿部署与 Canary 自动化上线支持
- 合约测试与混沌工程（注入失败验证稳定性）

---

📘 本文档将随着阶段推进持续更新  
建议与 `project-overview`、`infra-resources-detailed` 一并维护
# 🧾 项目阶段总结报告  
📄 文档名称：phase-report-20250422.md  
🗓️ 更新时间：2025-04-22  

---

## 🎯 本阶段目标

- 从 Cloudflare 单栈迁移为 Cloudflare + Firebase + Vercel 三元架构
- 完成基础任务链：Download → Metadata → AI 分析 → 状态协调
- 实现全链路 TraceId + 日志 + 异步队列 + 幂等消费
- 实现前端配置、查询界面及认证流程

---

## ✅ 已完成工作

- 架构重构：三平台职责边界明确
- Terraform 管理核心资源
- 所有 Worker 拆分部署并接入共享库
- 日志系统与 API Trace 完成
- Firebase 项目上线、Auth 接入完成
- 前端项目托管于 Vercel，支持多环境

---

## ⚠️ 仍在进行中

- 前端状态展示联调
- 向量搜索页面接入
- API 查询接口边界验证与错误处理优化
- 安全机制（权限细化、输入校验）增强中

---

## 🗺️ 下一阶段计划

- 发布可用 MVP 原型
- 扩展异步事件队列 + 插件订阅机制
- DLQ 自动回收机制上线
- 构建基础 Axiom 仪表盘
# 📚 project-handbook-20250420.md

## 📘 项目简介

本项目是一个基于 Cloudflare 架构栈构建的图片任务处理实验系统，聚焦于现代软件工程范式的落地演练。

## 🎯 项目目标

- 实践现代 Serverless + 事件驱动架构范式
- 构建高可观测性 + 模块化系统框架
- 验证 Cloudflare DO + Queues + R2 + D1 + Vectorize 组合能力
- 用于个人系统架构理解与技能训练

> ❗ 本项目为 **个人实验性工程项目**，并非商业产品，不追求用户体验与可用性极致，仅为展示架构与范式设计与实现路径。

## 🧱 项目结构略...

（此处略去其余已有内容，仅补充目标说明）

---

文档名：project-handbook-20250420.md  
更新日期：2025-04-22
# 📄 project-overview-20250422.md
📅 Updated: 2025-04-22

## 项目简介

iN 是一个面向现代软件工程实践的图像处理与智能索引系统，目标是完整演示 Serverless 架构、事件驱动机制、Durable Object 状态机、结构化日志、自动化 CI/CD、基础设施即代码（IaC）等核心能力。

该项目为 **非商业化产品**，以单人开发的工程探索为目标，不追求大规模并发、租户隔离或商业级插件能力。

## 当前架构概览

- Cloudflare 为主平台，使用 DO、R2、D1、Vectorize 等资源。
- Vercel 负责前端展示（通过 Cloudflare Pages 或 Edge Functions 可切换）。
- Firebase 仅承担辅助性任务（如认证配置）。

## 当前状态

- 架构与命名体系稳定，基础资源已通过 Terraform 定义。
- 核心流程（图片下载→元数据→AI 向量）链路设计明确，逻辑尚在编写中。
# 🔍 项目现状 vs 编程规则落实情况  
📄 文档名称：project-state-vs-guidelines-20250422.md  
🗓️ 更新时间：2025-04-22

---

## 🧱 架构与职责实现情况

| 模块 | 是否落地 | 说明 |
|------|-----------|------|
| Worker 拆分结构 | ✅ | apps/ 中已完成职责拆分（API、任务链） |
| Durable Object 状态机 | ✅ | task-coordinator 已实现状态更新接口 |
| Shared-libs 模块封装 | ✅ | logger/trace/auth/task/type 已分离完成 |
| 向量索引 + 日志系统 | ✅ | Vectorize 与 Logpush 均已配置 |
| Queue 驱动与幂等性 | ✅ | Download → Metadata → AI 流程均使用队列 |
| Event 模块与订阅机制 | ⚠️ 可选 | 已设计事件接口，尚未启用广播与订阅者 Worker |
| API 层 + Auth 集成 | ✅ | Gateway + Config API + Query API 完成，已对接 Firebase |
| 前端与后端联调 | 🔄 进行中 | 前端已托管 Vercel，API 对接正在完善 |
| 多租户能力 | ❌ | 尚未实现 tenantId 分区隔离逻辑 |
| 插件机制 | ❌ | 暂未引入事件生命周期挂载点 |

---

## ✅ CI/CD 与 IaC 状态

- GitLab CI Lint、Test、Build 已上线
- Terraform 已管理核心资源，后续补充日志/向量部分
- 环境变量使用同步脚本维护，Vercel/GitLab/CF 三方同步统一

---

## 📈 总体评价

基础架构 + 核心链路均已稳定打通，符合现代 Serverless 范式。文档、密钥、架构、职责已整体对齐，后续重点推进业务功能、前端对接、可观测系统完善与事件系统演进。
# 🔖 iN 项目资源命名规范清单  
📄 文档名称：resource-naming-list-20250422.md  
🗓️ 更新时间：2025-04-22  

---

## ☁️ Cloudflare 命名规范

格式：`in-<类型>-<顺序字母>-<功能名>-<日期>`

| 类型 | 示例 | 描述 |
|------|------|------|
| Worker | in-worker-a-api-gateway-20250402 | 所有 Worker 必须加顺序和功能名 |
| Queue | in-queue-b-image-download-20250402 | DLQ 使用邻接字母（如 c 为主，d 为 DLQ） |
| DO | in-do-a-task-coordinator-20250402 | Durable Object 命名空间 |
| R2 | in-r2-a-storage-bucket-20250402 | 原图存储桶 |
| D1 | in-d1-a-database-20250402 | 元数据数据库 |
| Vectorize | in-vectorize-a-index-20250402 | 向量索引结构 |
| Logpush | in-logpush-a-axiom-20250402 | 日志推送配置项 |

---

## 🔐 Firebase 命名规范

| 项目 | 示例 | 说明 |
|------|------|------|
| Firebase Project ID | in-fb-project-202504 | 建议与主项目一致，并带时间戳 |
| Firestore Collection | user-config | 存储用户配置项 preset |
| Auth Provider | google / github | OAuth 登录方式 |

---

## 🎨 Vercel 命名规范

| 项目 | 示例 | 说明 |
|------|------|------|
| Vercel Project Name | in-pages | 对应前端 SPA 项目 |
| 环境变量前缀 | PUBLIC_CONFIG_ | 前端使用的 ENV |
| 域名（默认） | in-pages.vercel.app | 可选自定义域名绑定 |

---

# ✅ 总结

所有资源命名需保持唯一性、规范性、可追踪性，并与 Terraform 一致对齐，确保日志与资源管理统一。
# 🔐 安全实践指南  
📄 文档名称：secure-practices-20250422.md  
🗓️ 更新时间：2025-04-22  

---

## ☁️ Cloudflare 安全策略

- 使用 `Secrets Store` 管理所有密钥，严禁硬编码
- 所有对外接口使用 `HMAC` 验签或 JWT 身份校验
- 每个 Worker 启用日志输出 traceId 以便溯源
- Durable Object 实现状态只允许特定 Worker 写入
- 所有 Queue 消费逻辑实现幂等处理（防止重放攻击）

---

## 🔐 Firebase 安全实践

- 使用 Firebase Auth 提供用户身份认证（支持 OAuth）
- 所有用户配置存储于 Firestore，规则限定为“仅允许本人读写”
- 在 `auth.ts` 中封装对 Firebase ID token 的解析与验证逻辑
- 禁用 Firebase Cloud Functions，避免平台分裂

---

## 🧬 Vercel 安全实践

- 通过 Vercel ENV 注入前端配置，避免前端硬编码
- 区分 `VERCEL_ENV`：dev, preview, production，对应不同后端 API
- 所有与 API 的通信需携带身份凭证（JWT/HMAC）
- 在前端构建阶段通过 `.env` 控制公开变量范围

---

## 📋 Secrets 与变量管理

- `.env.secrets` 为单一来源，手动维护
- 使用 `tools/sync-to-gitlab.sh` / `sync-runtime-to-cloudflare.sh` 同步变量
- Vercel ENV 可通过控制台或 CLI 设置（推荐以 `PUBLIC_` 前缀区分前端用）

---

## 🔁 其他建议

- 引入 Axiom 日志监控，设置异常告警阈值
- 使用 DLQ（Dead Letter Queue）捕获失败任务，避免任务死循环
- 所有传入参数建议使用 Zod 校验类型与范围
# ✅ security-checklist-20250422.md

## 🔐 基础安全措施清单

- [x] 所有密钥通过 `.env.secrets` 管理，使用 Secrets Store 同步到平台
- [x] 所有 API 均添加身份认证机制（Firebase Auth 或 JWT/HMAC）
- [x] 所有输入参数通过 Zod 进行输入验证
- [x] Git 历史已清理敏感信息，CI 集成 Gitleaks
- [x] 日志中不输出原始 secret 内容
- [x] 所有日志均附带 traceId，支持链路追踪
- [x] 日志结构化，使用 JSON 格式，推送至 Axiom
- [x] 队列消费严格幂等，避免重复副作用
- [x] Queue 消费失败进入 DLQ，主链不阻塞
- [x] Durable Object 状态更新不可越权

## 🆕 新增项

- [x] DLQ 记录不得包含原始用户敏感数据（如原图路径、用户 ID）
- [x] 所有 traceId 日志中应去除 secret 字段，仅保留任务与流程状态

---

文档名：security-checklist-20250422.md  
更新日期：2025-04-22
# 🧩 shared-libs-overview-20250422.md

## 🧱 主要共享模块

| 文件 | 功能 |
|------|------|
| logger.ts | 结构化 JSON 日志记录 |
| trace.ts | traceId 生命周期管理（生成/注入/传递） |
| auth.ts | JWT 与 HMAC 签名验证逻辑 |
| task.ts | 封装 DO 状态更新辅助逻辑 |
| events/ | 定义事件结构 INEvent<T> 以及类型化事件名 |

## 🔔 INEvent<T> 结构

```ts
type INEvent<T extends string, P = unknown> = {
  type: T;
  timestamp: number;
  traceId: string;
  taskId: string;
  payload: P;
};
```

## 📦 建议事件实现位置

- **事件发布**：在 Download/Metadata/AI Worker 中处理完成后立即 `publishEvent()`
- **事件订阅者**：单独 Worker 监听事件队列（如 log-enhancer）

---

文档名：shared-libs-overview-20250422.md  
更新日期：2025-04-22
# 📄 testing-guidelines-20250422.md
📅 Updated: 2025-04-22

## 测试策略概览

| 类型       | 工具      | 覆盖内容                         |
|------------|-----------|----------------------------------|
| 单元测试   | Vitest    | shared 库、逻辑函数              |
| 集成测试   | Wrangler  | Worker queue 消费逻辑            |
| E2E 测试   | -         | ❌ 当前尚未实现                  |

## 补充说明

目前项目**尚未实现 E2E 测试**，建议未来采用 Playwright 进行前后端基础链路联调验证，确保从前端操作至任务状态更新的闭环流程正确执行。
# 🧠 三元平台选型与职责划分决策记录  
📄 文档名称：three-tier-decision-notes-20250422.md  
🗓️ 更新时间：2025-04-22

---

## 🎯 背景

原始架构采用 Cloudflare 单栈实现，具备强一致性与边缘计算能力，但成本与复杂度偏高。为提升开发效率与交互体验，转为 Cloudflare + Firebase + Vercel 的“现代三元分布式架构”。

---

## 🧩 三元平台划分

| 平台 | 核心职责 | 使用组件 |
|------|------------|------------|
| ☁️ Cloudflare | 后端逻辑核心、任务流程控制 | Workers, Durable Object, Queues, R2, D1, KV, Vectorize, Logpush, AI |
| 🔐 Firebase | 用户身份认证与偏好配置 | Auth (OAuth 登录), Firestore (偏好配置存储) |
| 🎨 Vercel | 前端托管与用户交互页面 | Hosting, Preview Deployments, ENV 配置, SSR/SSG 支持 |

---

## ✅ 决策依据

- **Cloudflare**：继续作为任务状态中枢、数据处理核心，优势在于边缘分布式运行与高性能。
- **Firebase**：不承载核心处理逻辑，仅用于 OAuth 认证与 Firestore 配置（轻量非状态关键）。
- **Vercel**：仅用于 UI 渲染和页面托管，不处理任务流，最大化利用其静态部署与预览能力。

---

## 📌 使用策略总结

- Cloudflare 仍然主导系统处理链，不迁移 Durable Object、任务队列。
- Firebase 只做身份认证、preset 存储，禁用其 Cloud Functions 以避免架构分裂。
- Vercel 专注前端交互体验，使用 SvelteKit 实现 SPA 架构。

---

## 💡 经验结论

- 使用三元平台组合极大降低开发负担，加快迭代速度。
- 三者职责不交叉、互不干扰，完全可通过 ENV/Secret 管理实现无缝集成。
- 前端架构向桌面体验靠近，后端保持高性能、强一致控制，结构合理稳定。

---

# ✅ 总结

三元结构带来清晰的分工模型、优秀的性能体验与极佳的开发效率，是面向现代 Serverless 场景的最佳实践之一，适用于个人项目、中小型分布式系统或教育型架构演示项目。
