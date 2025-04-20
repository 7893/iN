# 📄 iN 项目全局概览与任务描述（20250420）

> 项目代号：**iN**（Intelligent Images Infrastructure Network）  
> 目标：**探索与实践现代软件工程核心范式**，构建一个分布式、可观测、AI 协同驱动的图片处理与索引系统。

---

## 🎯 项目总体目标

iN 项目并非传统业务系统，而是一个以技术试验、范式应用与工程能力展示为目的的现代架构工程。项目强调以下目标：

- 完整落地现代工程实践（EDA, IaC, FP, CI/CD, 可观测性等）
- 构建端到端异步图像处理流程（Download → Metadata → AI → Index）
- 实现边缘计算、任务流控制、状态机管理与副作用事件广播
- 实验 Cloudflare 原生平台的所有关键能力组件
- 设计适合教学、复用、拓展与长期演进的高可维护系统

---

## 🧱 架构与平台选型

| 平台 | 职责定位 | 主要使用组件 |
|------|-----------|----------------|
| Cloudflare | 主控系统与任务核心 | Workers, DO, Queue, R2, KV, D1, Vectorize, AI Gateway, Logpush |
| Firebase | 用户认证与配置辅助 | Auth, Firestore |
| Vercel | 前端展示与用户入口 | Hosting, ENV, Preview

---

## 📦 系统模块与功能组件

### 🧩 图像任务主链

- 配置任务（Config Worker / API）
- 下载图片（Download Worker）
- 提取元数据（Metadata Worker）
- AI 分析与向量化（AI Worker）
- 状态追踪（Durable Object）
- 事件广播（Event Queue）

### 💾 存储与数据管理

- Cloudflare R2：图像原图与副本存储
- Cloudflare D1：元数据、任务状态、配置存储
- Cloudflare Vectorize：向量化嵌入索引与查询
- KV：缓存与任务索引快照

### 📡 API 接口层

- API Gateway Worker：认证、traceId 注入、请求路由
- Config API：配置项管理、任务初始化
- Image API：任务状态查询、图像列表与详情
- （可选）Image Mutation / Search API：未来增强项

### 🔐 安全与认证

- Firebase Auth：用户 OAuth 登录
- JWT/HMAC 验证：API 层身份校验
- Secrets Store：敏感密钥统一管理

### 🔍 可观测性系统

- `logger.ts`：标准化 JSON 日志格式输出
- `trace.ts`：全链路 traceId 管理
- Cloudflare Logpush：推送日志至 Axiom
- Axiom：日志聚合、仪表盘、告警规则配置

---

## 🌀 混合事件驱动架构

- 主流程由任务队列驱动（Download → Metadata → AI）
- Durable Object 统一协调状态（幂等控制、任务推进）
- Event Queue 异步广播副作用（日志通知、向量索引、推荐）
- 事件接口统一于 shared-libs/events，确保结构规范
- 所有订阅 Worker 强制幂等、副作用处理可插拔

---

## 🛠 工程实践概览

| 范式 | 落地方式 |
|------|-----------|
| 函数式编程 | 纯函数封装副作用，任务处理幂等 |
| 基础设施即代码 | Terraform 管理全部资源，版本可控 |
| 可观测性 | 全链 traceId + Logpush + Axiom 仪表盘 |
| CI/CD | GitLab CI 部署、自动测试、同步密钥 |
| 模块化架构 | Worker 独立部署，Shared Libs 封装核心逻辑 |
| 命名规范 | in-worker-a-api-20250402 格式，统一追踪性 |

---

## 🪜 实施阶段（摘要）

| 阶段 | 内容概述 |
|------|----------|
| 0 | 项目结构、工具链、Terraform 初始化 |
| 1 | 核心资源（R2, D1, Queue, Vectorize）创建 + Shared Lib 实现 |
| 2 | Download → Metadata → AI 主任务链 + Durable Object 状态机 |
| 3 | API 网关与核心接口构建 + 认证机制 |
| 4 | 前端开发 + 接口集成 + 用户流程闭环 |
| 5 | 日志验证、Axiom 接入、告警配置、安全增强与性能优化

---

## 🧩 未来扩展方向

- 插件系统（事件订阅 / 钩子注入）
- 多租户支持（Tenant ID 隔离）
- Feature Flags 与灰度发布
- 向量搜索功能增强（场景推荐、图像去重）
- 零信任安全模型接入（Cloudflare Access）

---

## 📚 文档结构说明

- 所有文档统一存放于 `~/in/docs/`，kebab-case 命名
- 分类包含：架构文档、工程指南、安全规范、阶段计划、资源命名、开发手册等
- 示例文件名：`platform-architecture-summary-20250420.md`, `secure-practices.md`, `phased-implementation.md`

---

## 👤 项目主导者

> 本项目由开发者 @79 独立主导，使用生成式 AI（Gemini, GPT-4o, Grok）辅助实现全部架构、文档与部分代码。  
> 旨在构建一个体现现代架构美学与工程范式的个人级“系统作品”，具备教学传播价值、工程演示价值与长期演进可能。

