# 🚀 iN Project – Intelligent Image Infrastructure on Cloudflare

> 一套以现代架构范式为核心构建的智能图像处理系统  
> 聚焦 Serverless、事件驱动、分布式状态协调与可观测性全链路落地

---

## 🎯 项目定位

**iN 是一个面向现代软件工程实践的全栈架构范例**，通过实际构建智能图像处理平台，系统性演示以下范式落地：

- ☁️ Serverless 全家桶设计（Cloudflare 为主）
- 📩 事件驱动 + 消息队列主链协调机制
- 🧠 Durable Object 分布式状态管理
- 📊 全链路结构化日志 + Logpush 可观测性接入
- 🔐 零信任安全 + 密钥隔离管理
- 🛠️ 基础设施即代码（IaC） + 自动化 CI/CD 流程

所有架构设计、文档与核心代码均由 **生成式人工智能** （ChatGPT-4o、Gemini Pro 2.5、Grok 3）协同产出，代表当下 AI 辅助工程的前沿实践路径。

---

## 🧱 核心技术栈概览

| 层级 | 技术选型 | 说明 |
|------|------------|------|
| 前端展示 | Vercel + Cloudflare Pages | 配置与图片状态 UI |
| API 接口 | Cloudflare Workers | 网关、配置、查询、检索接口 |
| 主任务链 | Queue + Durable Object + Worker | 下载 → 元数据提取 → AI 向量生成 |
| 存储体系 | R2 / D1 / Vectorize | 原图 + 结构化数据 + 向量索引 |
| 用户认证 | Firebase Auth | 用户级访问控制 |
| 可观测性 | Axiom + TraceId + JSON Log | 实现日志追踪与故障定位 |
| 基础设施管理 | Terraform + GitLab CI | 所有资源与部署全自动化 |

---

## ✅ 已实现工程亮点

- **架构模块划分清晰、职责分离明确**
- **任务流程通过 Durable Object 实现强一致状态控制**
- **队列驱动的事件分发解耦主流程与副作用**
- **TraceID + Logpush 构建可审计日志流**
- **Worker 幂等性强制约束提升系统稳定性**
- **文档完整、命名规范、CI/CD 流程清晰可复用**
- **平台解耦设计，三元组合部署灵活（VC + FB + CF）**

---

## 🧪 MVP 范围

- 图片任务配置与采集触发  
- 下载 → 元数据提取 → AI 向量链路闭环  
- 原图 + 数据存储 + 向量检索接口  
- 可视化状态展示页面（Vercel）  
- DLQ 自动检测与日志增强事件订阅者（计划中）

---

## 📁 仓库结构概览

```
├── apps/              # 所有前端 + Worker 应用
├── packages/          # 共享库（日志、追踪、认证、事件）
├── infra/             # Terraform 定义与输出
├── docs/              # 架构说明、命名规范、安全策略等工程文档
├── tools/             # 密钥同步、清理与辅助脚本
└── README.md
```

---

## 🧠 架构指导原则

- **主流程同步控制、旁路异步广播**
- **事件即事实、不可逆但可重放**
- **状态统一落点、任务逻辑幂等**
- **基础设施即代码、部署即定义**
- **日志可结构化追踪、事件可插拔处理**

---

## 🧭 推荐阅读

项目完整文档体系请见 [`/docs`](./docs)，推荐起步：

- `architecture-summary-*.md` 架构总览与模块责任划分
- `phased-implementation-*.md` 分阶段开发路径指引
- `secure-practices-*.md` 安全机制实践指南
- `testing-guidelines-*.md` 当前测试现状与补充建议
- `action-checklist-*.md` 当前开发重点任务追踪

---

📅 文档更新日期：2025-04-22  
📌 本项目设计、代码与文档全部由生成式人工智能（ChatGPT-4o, Gemini Pro 2.5, Grok 3）协作完成。
