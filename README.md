# 🚀 iN Project – Intelligent Image Infrastructure on Cloudflare

> 高性能、事件驱动、分布式图片智能处理系统  
> 构建于 Cloudflare 全家桶的现代 Serverless 平台  

---

📖 查看更新日志：[CHANGELOG.md](./CHANGELOG.md)

🧠 本项目虽然功能看似简单，但其核心目的并非构建某个实际服务，而是**探索并实践现代软件工程的多种关键范式与架构理念**。  
从架构设计到部署流程，再到文档生成，力求体现当下优秀的工程方法，保持清晰、可扩展、可观测、可维护的系统构造。  

> 本项目的**全部核心代码与文档均由生成式人工智能协助完成**，具体使用：
> - 🔵 Gemini 2.5 Pro （主力架构生成与模块逻辑设计）
> - 🟣 ChatGPT-4o （用于排查问题、辅助语言表达与优化脚本）
> - ⚫ Grok 3 （辅助逻辑排查与生成调试示例）

---

## 📦 Monorepo 概览

```
├── apps/                  # 各类可部署应用（Workers, 前端等）
│   ├── in/                # 前端 (Cloudflare Pages)
│   ├── in-worker-a-api-gateway/       # API 网关 Worker
│   ├── in-worker-d-download/          # 下载 Worker
│   └── ...
├── packages/              # 共享逻辑与库（如日志、认证、状态协调等）
│   ├── shared-libs/       # 日志、追踪、认证、任务状态逻辑等
│   └── ...
├── infra/                 # Terraform 基础设施定义
├── tools/                 # 实用工具脚本（Secrets 同步、清理等）
└── .gitlab-ci.yml         # CI/CD 流水线配置
```

---

## 🧠 项目简介

**iN 是一套现代化的图片处理与检索系统，具备以下能力：**
- 🌉 多源图片采集（可配置）
- 🧾 元数据提取（尺寸、格式、EXIF）
- 🤖 AI 分析（向量化、文本描述生成）
- 📦 原图 + 数据存储（R2 + D1 + Vectorize）
- 🔍 智能搜索与 API 查询
- 📊 可观测性全链路追踪（Logpush + Axiom）
- 🧩 模块化任务管线与事件驱动架构
- 🔐 JWT/HMAC 安全认证体系

---

## 🏗️ 架构总览

| 组件 | 技术 | 说明 |
|------|------|------|
| Frontend | Cloudflare Pages | 用户界面，配置与任务触发 |
| API 层 | Workers A/B/G/H/I/J | API Gateway + 配置管理 + 查询接口 |
| 核心处理流程 | Workers C/D/E/F + Queues + DO | 下载 → 元数据 → AI → 状态跟踪 |
| 存储 | R2 / D1 / Vectorize | 原图、结构化信息与向量 |
| 状态协调 | Durable Object | 单任务状态机协调器 |
| 日志追踪 | logger.ts + Logpush + Axiom | Trace ID 结构化日志 |
| 安全 | auth.ts + Secrets Store | JWT/HMAC 验证 + 密钥统一管理 |
| IaC | Terraform + GitLab | 所有资源基础设施即代码管理 |
| CI/CD | GitLab CI | 自动部署与构建流程（进行中） |
| 工具链 | pnpm, Turborepo, Wrangler, Vitest |

---

## 🌟 项目亮点 – 现代工程范式全覆盖

### ✅ 当前已落地的工程实践

| 范式 / 能力 | 实现方式 |
|-------------|-----------|
| 🧱 模块化架构 | Worker 拆分、职责单一，Monorepo 管理结构清晰。 |
| 🔄 异步解耦架构 | 使用 Cloudflare Queues 驱动三段式任务链。 |
| 🧠 幂等性处理 | 所有 Worker 强制幂等消费，防止重复影响状态。 |
| 📍 状态一致性协调 | Durable Object 实现任务状态机，流程稳定可控。 |
| 🧬 函数式编程范式 | 共享副作用封装，代码风格鼓励纯函数与不可变。 |
| 📦 基础设施即代码 | Terraform 管理所有 Cloudflare 资源。 |
| 🔐 Secrets 管理 | `.env.secrets` + 同步脚本双向覆盖 CF + GitLab。 |
| 📊 日志与追踪 | TraceID + JSON 日志输出，Logpush 推送至 Axiom。 |
| 🔁 可重复部署 | 资源命名规范，Worker 独立部署，追踪性强。 |
| 🧪 测试体系 | 使用 Vitest 为共享库与核心逻辑编写测试。 |
| 💡 CI/CD 准备 | GitLab CI + 分阶段部署流水线结构完善中。 |
| 🔎 命名规范 | 统一 `in-<类型>-<编号>-<功能>-<日期>` 命名。 |

---

### 🧭 即将落地 / 规划中能力

| 能力 | 规划内容 |
|------|----------|
| 🧩 插件系统 | 注册钩子生命周期，允许扩展 Worker 插件功能。 |
| 🌐 多租户支持 | 引入 `tenantId`，实现数据隔离与权限粒度控制。 |
| 🚦 Feature Flags | 使用 D1 管理运行时开关，实现灰度与热更新。 |
| 🔁 混沌工程 | 注入异常任务验证系统自愈能力。 |
| 📈 SLA / SLO | 构建延迟、错误率等核心指标仪表盘 + 告警。 |
| 🔐 Zero Trust 安全 | 接入 Cloudflare Access + HMAC 强安全认证。 |
| 📬 可观测事件流 | 引入 Event Queue 与订阅者 Worker 扩展副作用逻辑。 |
| 🔄 Canary/蓝绿部署 | 引入灰度上线与自动回滚流程。 |
| 🤝 合约 / Canary 测试 | OpenAPI Schema 驱动验证 + 前置集成测试机制。 |

---

## 📁 快速开始

```bash
# 克隆仓库并初始化依赖
git clone git@gitlab.com:79/in.git
cd in
pnpm install

# 启动本地 Worker
cd apps/in-worker-d-download
wrangler dev
```

---

## 🔐 密钥与环境变量

- 所有密钥集中于 `.env.secrets`，统一通过脚本同步：
  - `tools/sync-runtime-to-cloudflare.sh`
  - `tools/sync-to-gitlab.sh`

---

## 👤 作者

项目由个人开发者 @79 主导设计与实现，融合现代工程实践与 Cloudflare 原生架构，目标是以最小开发体量实现最大系统扩展性、维护性与教学价值。

欢迎交流 🚀
