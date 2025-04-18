# 🚀 iN Project – Intelligent Image Infrastructure on Cloudflare

> 高性能、事件驱动、分布式图片智能处理系统  
> 构建于 Cloudflare 全家桶的现代 Serverless 平台  

---

📖 查看更新日志：[CHANGELOG.md](./CHANGELOG.md)

🧠 虽然功能看似简单，但 iN 项目的目标是探索并实践现代软件工程的核心范式。它不仅是一个图片处理系统，更是一套融合“**狠、准、稳、美**”四大特质的工程样本：

---

### 💥 狠 —— 架构出手即现代范式
- 异步队列 + Durable Object 构建任务状态机；
- 幂等性保障、结构化日志、全链路追踪；
- 模块划分清晰，支持插件扩展与未来混沌工程演练。

### 🎯 准 —— 工程结构精准清晰
- Monorepo 管理：apps/ 管 Worker，packages/ 管逻辑，infra/ 管资源；
- 所有模块命名统一、资源规范，源码可读性极高；
- 分支策略、CI/CD 阶段、配置粒度清晰明确。

### 🛡️ 稳 —— 自动化保障项目稳定推进
- CI 集成 Gitleaks 自动扫描敏感信息；
- Cloudflare Secrets Store、Terraform 管理基础设施；
- 所有关键模块均带测试与日志追踪，支持快速定位问题。

### ✨ 美 —— 文档、配置、结构全面规范
- README、CHANGELOG、架构说明文档齐全；
- 项目组件职责单一，结构优雅；
- 所有代码与文档均由 AI 工具（Gemini 2.5 Pro 为主，辅以 ChatGPT-4o 和 Grok 3）协助生成，体现 AI 时代的现代工程范式。

---

## 📦 Monorepo 概览

```
├── apps/                  # 可部署 Worker + Pages
├── packages/              # 共享逻辑与工具
├── infra/                 # Terraform 资源管理
├── tools/                 # Secrets 同步等工具脚本
├── docs/                  # 架构与命名文档
├── .gitlab-ci.yml         # CI/CD 配置
└── ...                    # 其他配置与元数据
```

---

## 📁 快速开始

```bash
# 克隆项目并安装依赖
git clone git@gitlab.com:79/in.git
cd in
pnpm install

# 启动本地 Worker（示例）
cd apps/in-worker-d-download
wrangler dev
```

---

## 🔐 密钥管理策略

- 所有密钥集中在 `.env.secrets`
- 使用以下脚本自动同步：
  - `tools/sync-runtime-to-cloudflare.sh`
  - `tools/sync-to-gitlab.sh`

---

## 🧪 安全扫描与测试

- ✅ Gitleaks 集成于 GitLab CI，自动扫描所有提交；
- ✅ 所有共享库具备 Vitest 单元测试；
- ✅ 前端支持完整 Lint + Build 流程；
- ✅ 所有日志具备 traceId，支持 Axiom 集成观测。

---

## 👤 作者

本项目由个人开发者 @79 主导构建，旨在将现代架构、自动化工程与 AI 编程理念落地实践。  
代码不仅能用，更是一套“可以学习、可推广、可演进”的 Serverless 架构范式。

欢迎交流 🚀
