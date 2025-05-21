# 🚀 iN Project – Intelligent Image Infrastructure on Vercel, Cloudflare & GCP

> 一套以现代架构范式为核心构建的智能图像处理系统  
> 聚焦 Serverless、事件驱动（GCP Pub/Sub）、分布式状态协调（Cloudflare DO）与可观测性（GCP Logging）全链路落地，采用 Vercel、Cloudflare、GCP 和 GitHub 构建。

---

## 🎯 项目定位

**iN 是一个面向现代软件工程实践的全栈架构范例**，通过实际构建智能图像处理平台，系统性演示以下范式落地：

- ☁️ 多云 Serverless 架构设计（Vercel 前端, Cloudflare 边缘, GCP核心后端）
- 📩 事件驱动机制（**Google Cloud Pub/Sub** 为核心消息队列）
- 🧠 Durable Object (Cloudflare DO) 分布式状态管理
- 📊 全链路结构化日志 + **Google Cloud Logging & Monitoring** 可观测性接入
- 🔐 零信任安全 + 密钥隔离管理（**GCP Identity Platform** + Cloudflare Secrets）
- 🛠️ 基础设施即代码（IaC） + 自动化 CI/CD 流程（**GitHub Actions**）

所有架构设计、文档与核心代码均由 **生成式人工智能** （例如 Gemini）协同产出，代表当下 AI 辅助工程的前沿实践路径。

---

## 🧱 核心技术栈概览 (架构版本 2025年5月21日)

| 层级             | 技术选型                                     | 说明                                         |
| ---------------- | -------------------------------------------- | -------------------------------------------- |
| 前端展示         | **Vercel** (例如 SvelteKit/Next.js 应用)          | 高性能用户界面，由 Vercel 托管和全球分发        |
| CDN & 安全       | Cloudflare                                   | 全球加速、DDoS防护、WAF                      |
| API 接口         | Cloudflare Workers                           | 边缘API网关、轻量级业务逻辑                  |
| 状态协调         | Cloudflare Durable Objects                   | 任务生命周期状态管理                         |
| 消息队列         | **Google Cloud Pub/Sub** | 核心任务链的异步消息传递与解耦               |
| 核心后端计算     | **Google Cloud Functions / Cloud Run** | 图片下载、元数据提取、AI分析等核心处理         |
| 对象存储         | Cloudflare R2 / **Google Cloud Storage (GCS)** | 原图、处理结果、静态资源存储                 |
| 结构化数据       | Cloudflare D1 / **GCP Firestore (Native)** | 结构化元数据、任务记录                       |
| 向量存储         | Cloudflare Vectorize / **GCP Vertex AI Vector Search (可选)** | 图像向量索引                                 |
| 用户认证         | **Google Cloud Identity Platform (GCIP)** | 用户级访问控制                               |
| 可观测性         | **Google Cloud Logging & Monitoring** | 实现日志追踪与故障定位                       |
| 基础设施管理     | Terraform + **GitHub Actions** | Cloudflare 与 GCP 资源自动化管理             |
| 代码托管与 CI/CD | **GitHub** / **GitHub Actions** | 版本控制与自动化流程                         |

---

## ✅ 工程亮点 (基于新架构调整)

- **清晰的多云职责划分**：Vercel (前端), Cloudflare (边缘网关与状态协调), GCP (核心后端逻辑与数据服务)。
- **任务流程通过 Cloudflare Durable Object 实现强一致状态跟踪**，**Google Cloud Pub/Sub 驱动事件分发**，解耦主流程与副作用。
- **TraceID + Google Cloud Logging 构建可审计、可追踪的日志流**。
- **各 Serverless 计算单元 (CF Workers, GCP Cloud Functions/Run) 强制幂等性约束**，提升系统稳定性。
- **文档完整、命名规范、CI/CD 流程（GitHub Actions）清晰可复用**。
- **平台解耦设计，三元组合部署灵活（Vercel + Cloudflare + GCP）**。

---

## 🧪 MVP 范围 (基于新架构调整)

- 图片任务配置与采集触发 (通过 Vercel 前端调用 Cloudflare API 网关)。
- 下载 → 元数据提取 → AI 向量链路闭环（由 GCP Pub/Sub 驱动，GCP Cloud Functions/Run 执行，状态由 Cloudflare DO 协调）。
- 原图 (R2/GCS) + 数据存储 (D1/GCP Firestore) + 向量检索接口 (Cloudflare Vectorize / GCP Vertex AI)。
- 可视化状态展示页面（Vercel）。
- GCP Pub/Sub 死信主题 (Dead-Letter Topics) 自动检测与基础日志告警 (GCP Monitoring)。

---

## 🧠 架构指导原则

- **Vercel 极致前端体验、Cloudflare 边缘加速与安全、GCP 强大后端支撑。**
- **核心流程由 GCP Pub/Sub 异步驱动，Cloudflare DO 精细化状态协调。**
- **事件即事实、不可逆但可重放（利用 Pub/Sub 特性）。**
- **状态统一落点（DO）、任务逻辑幂等。**
- **基础设施即代码（Terraform）、部署即定义（GitHub Actions）。**
- **日志可结构化追踪（GCP Logging）、事件可插拔处理（Pub/Sub 订阅）。**

---

## 🧭 推荐阅读 (文档需更新)

项目完整文档体系请见 [`/docs`](./docs)，更新后的文档将反映新的架构，推荐起步阅读：

- `architecture-summary-*.md` (新版) 架构总览与模块责任划分
- `phased-implementation-*.md` (新版) 分阶段开发路径指引
- `secure-practices-*.md` (新版) 安全机制实践指南（含 GCIP 和 GCP 服务）
- `testing-guidelines-*.md` (新版) 当前测试现状与补充建议
- `action-checklist-*.md` (新版) 当前开发重点任务追踪

---

📅 文档更新日期：2025-05-21  
📌 本项目设计、代码与文档在新的多云架构指导下，继续由生成式人工智能协作完成。