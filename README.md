# 🚀 iN Project – Intelligent Image Infrastructure on Vercel, Cloudflare & GCP

> 一套以现代架构范式为核心构建的智能图像处理系统  
> 聚焦 Serverless、事件驱动（GCP Pub/Sub）、分布式状态协调（Cloudflare DO 负责最终/摘要状态）与可观测性（GCP Logging）全链路落地，采用 Vercel、Cloudflare、GCP 和 GitHub 构建。

---

## 🎯 项目定位

**iN 是一个面向现代软件工程实践的全栈架构范例**，通过实际构建智能图像处理平台，系统性演示以下范式落地：

- ☁️ 多云 Serverless 架构设计（Vercel 前端, Cloudflare 边缘, GCP核心后端）
- 📩 事件驱动机制（**Google Cloud Pub/Sub** 为核心消息队列驱动GCP内部流程）
- 🧠 Durable Object (Cloudflare DO) **最终/摘要状态**管理与边缘协调
- 📊 全链路结构化日志 + **Google Cloud Logging & Monitoring** 可观测性接入
- 🔐 零信任安全 + 密钥隔离管理（**GCP Identity Platform** + 各平台Secrets）
- 🛠️ 基础设施即代码（IaC） + 自动化 CI/CD 流程（**GitHub Actions**）

所有架构设计、文档与核心代码均由 **生成式人工智能** （例如 Gemini）协同产出，代表当下 AI 辅助工程的前沿实践路径。

---

## 🧱 核心技术栈概览 (架构版本 2025年5月21日 - 优雅优先)

| 层级                 | 技术选型                                         | 说明                                                                 |
| -------------------- | ------------------------------------------------ | -------------------------------------------------------------------- |
| 前端展示             | **Vercel** (例如 SvelteKit/Next.js 应用)              | 高性能用户界面，由 Vercel 托管和全球分发                                 |
| CDN & 安全           | Cloudflare                                       | 全球加速、DDoS防护、WAF                                              |
| API 接口             | Cloudflare Workers                               | 边缘API网关、轻量级业务逻辑、GCIP Token验证、DO交互、Pub/Sub消息发布入口 |
| **状态协调 (最终/摘要)** | Cloudflare Durable Objects                       | 任务**最终或关键摘要状态**管理，接收GCP流程完成后的回调                    |
| 消息队列             | **Google Cloud Pub/Sub** | 驱动GCP内部核心任务链的异步消息传递与解耦                                |
| 核心后端计算         | **Google Cloud Functions / Cloud Run** | 图片下载(到GCS)、元数据提取、AI分析等核心处理，由Pub/Sub触发              |
| **GCP内部状态存储** | **GCP Firestore (Native Mode) / Datastore** | 存储GCP内部各处理阶段的详细状态、元数据、任务记录（DO状态的补充）            |
| 对象存储             | **Google Cloud Storage (GCS)** / Cloudflare R2 | GCS作为GCP流程主要对象存储；R2可选用于最终分发或边缘缓存                  |
| 结构化数据 (边缘)  | Cloudflare D1                                    | (可选) 存储需要从边缘快速访问的摘要元数据或DO关联数据                      |
| 向量存储             | Cloudflare Vectorize / **GCP Vertex AI Vector Search (可选)** | 图像向量索引                                                             |
| 用户认证             | **Google Cloud Identity Platform (GCIP)** | 用户级访问控制                                                         |
| 可观测性             | **Google Cloud Logging & Monitoring** | 实现日志追踪与故障定位                                                     |
| 基础设施管理         | Terraform + **GitHub Actions** | Cloudflare 与 GCP 资源自动化管理                                         |
| 代码托管与 CI/CD     | **GitHub** / **GitHub Actions** | 版本控制与自动化流程                                                     |

---

## ✅ 工程亮点 (基于优雅优先架构调整)

- **清晰的多云职责划分**：Vercel (前端), Cloudflare (边缘网关与最终/摘要状态协调), GCP (核心后端逻辑、数据服务与详细状态)。
- **任务流程由 Google Cloud Pub/Sub 驱动GCP内部事件分发**，Cloudflare Durable Object 实现**最终/摘要状态的强一致跟踪**。
- **TraceID + Google Cloud Logging 构建可审计、可追踪的日志流**。
- **各 Serverless 计算单元 (CF Workers, GCP Cloud Functions/Run) 强制幂等性约束**，提升系统稳定性。
- **文档完整、命名规范、CI/CD 流程（GitHub Actions）清晰可复用**。
- **平台解耦设计，三元组合部署灵活（Vercel + Cloudflare + GCP），并优化了跨云交互频率**。

---

## 🧪 MVP 范围 (基于优雅优先架构调整)

- 图片任务配置与采集触发 (通过 Vercel 前端调用 Cloudflare API 网关，API网关发布到GCP Pub/Sub)。
- 下载 → 元数据提取 → AI 向量链路闭环（由 GCP Pub/Sub 驱动，GCP Cloud Functions/Run 执行，**详细状态记录在GCP Firestore**，最终状态回调 Cloudflare DO）。
- 原图 (GCS/R2) + 数据存储 (GCP Firestore/D1) + 向量检索接口 (Cloudflare Vectorize / GCP Vertex AI)。
- 可视化状态展示页面（Vercel，主要查询Cloudflare DO中的摘要/最终状态）。
- GCP Pub/Sub 死信主题 (Dead-Letter Topics) 自动检测与基础日志告警 (GCP Monitoring)。

---

## 🧠 架构指导原则 (基于优雅优先调整)

- **Vercel 极致前端体验、Cloudflare 边缘加速与安全、GCP 强大后端支撑。**
- **核心流程由 GCP Pub/Sub 在GCP内部异步驱动，Cloudflare DO 负责最终/摘要状态的精细化协调，减少跨云回调。**
- **数据尽可能靠近计算单元，GCS作为GCP内部处理的主要对象存储。**
- **事件即事实、不可逆但可重放（利用 Pub/Sub 特性）。**
- **状态主要落点（DO用于最终/摘要状态，GCP Firestore用于详细过程状态）、任务逻辑幂等。**
- **基础设施即代码（Terraform）、部署即定义（GitHub Actions）。**
- **日志可结构化追踪（GCP Logging）、事件可插拔处理（Pub/Sub 订阅）。**

---

## 🧭 推荐阅读 (文档需更新)

项目完整文档体系请见 [`/docs`](./docs)，更新后的文档将反映新的优雅架构，推荐起步阅读：

- `architecture-summary-*.md` (新版) 架构总览与模块责任划分
- `phased-implementation-*.md` (新版) 分阶段开发路径指引
- `secure-practices-*.md` (新版) 安全机制实践指南（含 GCIP 和 GCP 服务）
- `testing-guidelines-*.md` (新版) 当前测试现状与补充建议
- `action-checklist-*.md` (新版) 当前开发重点任务追踪

---

📅 文档更新日期：2025年5月21日 23:01 (CST)
📌 本项目设计、代码与文档在新的多云优雅架构指导下，继续由生成式人工智能协作完成。