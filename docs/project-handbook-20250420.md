# 📖 iN 项目手册（Project Handbook）- 20250420 更新版

> 本文档详细说明 iN 项目的整体定位、目标、架构、技术选型、职责划分与实施策略，已整合 Cloudflare、Firebase 与 Vercel 三元架构的最新变更。

---

## 🎯 项目目标与核心定位

**iN (Intelligent Images Infrastructure Network)** 是一个致力于实践与探索现代软件工程核心范式的架构试验项目。它并非为某具体业务构建的服务，而是用于展示如何构建：

- 现代化异步任务处理系统（事件驱动架构）
- 边缘计算与云原生能力融合（Serverless + Edge）
- 模块化架构与可扩展系统设计
- 强一致性与幂等性任务流程（状态机模式）
- 可观测性与结构化日志体系
- 安全与认证的最佳实践（HMAC, JWT, OAuth）
- 基础设施即代码（IaC）管理与自动化 CI/CD

---

## 🧱 最新架构概览（Cloudflare × Firebase × Vercel）

本项目已正式调整为以 Cloudflare 为核心，Firebase 和 Vercel 为辅助平台的“三元架构”：

| 平台 | 核心职责定位 | 使用组件 |
|------|-----------|------------|
| Cloudflare ☁️ | 主后端、任务驱动中枢 | Workers, Durable Object, Queues, R2, KV, D1, Vectorize, AI Gateway, Logpush |
| Firebase 🔐 | 用户认证与配置存储 | Auth (OAuth 登录), Firestore (用户偏好与配置存储) |
| Vercel 🎨 | 前端界面与用户交互入口 | Hosting, ENV, Preview (部署与 SSR/ISR 支持) |

---

## 📦 功能模块与职责划分（详细）

### 🌉 图像任务处理流水线

- 配置任务 (Config Worker)
- 图片下载与存储 (Download Worker → R2 Bucket)
- 提取图片元数据 (Metadata Worker → D1)
- AI 分类分析与向量嵌入 (AI Worker → Vectorize Index)
- 状态机管理与协调 (Durable Object)

### 🌐 API 接口体系

- API Gateway Worker: 请求路由、认证管理、traceId 注入
- Config API Worker: 配置 CRUD 管理与任务触发
- Image Query API Worker: 任务状态与结果查询
- Image Search API (未来扩展): 向量化搜索与推荐

### 📊 可观测性与日志体系

- TraceID 全链路贯穿（trace.ts）
- JSON 结构化日志输出（logger.ts）
- 日志推送与聚合 (Cloudflare Logpush → Axiom)
- 仪表盘与告警（Axiom Dashboard 配置）

### 🔐 安全认证机制

- JWT / HMAC 接口认证 (auth.ts)
- OAuth 用户登录与 token 管理（Firebase Auth）
- Secrets Store 统一密钥管理（Cloudflare）

### 🎨 前端界面（Vercel Pages）

- 用户登录与认证对接 Firebase
- 用户 preset 与收藏夹管理
- 任务配置与触发按钮
- 图片结果列表展示与状态查询
- 基于 ENV 环境变量的动态配置支持

---

## 🚧 实施与阶段策略

项目分阶段实施策略：

| 阶段 | 任务目标 |
|------|-----------|
| 阶段 0️⃣ | 项目 Monorepo 初始化，Terraform 基础环境搭建 |
| 阶段 1️⃣ | 创建核心 Cloudflare 资源，搭建共享库（日志、追踪、认证） |
| 阶段 2️⃣ | 实现任务处理主链（下载、元数据、AI）与状态机逻辑 |
| 阶段 3️⃣ | 构建 API Gateway、集成 Firebase Auth、配置接口 |
| 阶段 4️⃣ | 前端开发与后端集成（Vercel） |
| 阶段 5️⃣ | 完善可观测性、日志、告警配置、安全加固与性能优化 |

---

## 👤 项目发起人与主导者

项目由个人开发者 @79 全程主导设计与开发，通过以下生成式人工智能辅助构建：

- Gemini 2.5 Pro (核心架构与逻辑设计)
- ChatGPT-4o (问题排查、文档优化、脚本生成)
- Grok 3 (辅助逻辑调试与示例生成)

本项目旨在演示并推广现代架构工程实践的优秀范式，具备高度的教学价值、实践参考与长期演进潜力。

