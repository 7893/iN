# iN 项目文档索引

📁 本文档库包含架构设计、开发指南、系统组件、参考规范、CI/CD 与安全文档等，结构清晰，按功能分类，方便查阅。

---

## 📦 目录结构与说明

```
docs/
├── index.md                         # 📚 当前索引文档（本页）
├── architecture/                   # 🏗 架构设计与核心概念
│   ├── overview.md                 # 项目总体架构概要（系统目标、技术栈、模块分层）
│   ├── components.md              # 各核心组件职责说明（API、Worker、Queue、存储等）
│   └── event-architecture.md      # 混合事件驱动架构（任务队列 + 事件队列设计）
├── guides/                         # 🛠 开发与部署指南
│   ├── local-dev.md               # 本地开发指南（使用 wrangler, pnpm, Turbo）
│   ├── plugin-guide.md            # 插件机制说明（如何开发与挂载插件）
│   ├── terraform-deploy.md        # 使用 Terraform 部署 Cloudflare 资源的流程
│   └── troubleshooting.md         # 常见问题排查（如部署失败、认证错误）
├── reference/                      # 📘 技术参考与命名规范
│   ├── event-types.md             # 所有事件类型枚举及用途（Pub/Sub 标准事件列表）
│   ├── glossary.md                # 专有术语表（iN 项目常见术语释义）
│   ├── iN-components.md           # iN 系统资源清单（Worker、Queue、DO、R2、D1等）
│   ├── naming-conventions.md      # 资源与命名规范（统一 Worker、Queue、资源命名）
│   ├── shared-utils.md            # Shared Libraries 简介（logger.ts、auth.ts 等）
│   └── status-codes.md            # 系统状态码与任务流程状态列表
├── systems/                        # 🔐 系统支持能力
│   ├── ci-cd.md                   # CI/CD 设计与实践（GitHub Actions + Turbo）
│   ├── config.md                  # 配置结构与加载机制说明
│   ├── logging.md                 # 日志设计（结构化日志、traceId、Logpush）
│   └── security.md                # 安全设计（AuthN/AuthZ、HMAC、Secrets 管理）
└── workers/                        # 👷 各 Worker 逻辑说明（持续补充中）
    ├── ai-worker.md               # ai-worker 的职责与运行逻辑
    ├── download-worker.md        # download-worker 的工作流程
    └── eventbus-worker.md        # 事件总线 worker（处理事件发布/订阅中枢）
```

---

## 📎 使用建议

- 建议先阅读 [`architecture/overview.md`](architecture/overview.md) 了解整个系统的设计全貌；
- 在开发阶段，可参考 [`guides/local-dev.md`](guides/local-dev.md) 和 [`systems/config.md`](systems/config.md) 快速启动；
- 若需添加资源或配置，请先查阅 [`reference/naming-conventions.md`](reference/naming-conventions.md) 和 [`reference/iN-components.md`](reference/iN-components.md)。

---

如需添加/修改此目录，请编辑 `docs/index.md` 文件。
