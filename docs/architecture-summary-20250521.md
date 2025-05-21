# 🏗️ architecture-summary-20250521.md (优雅优先版)

iN 项目采用现代分布式多云架构，以 Vercel 提供前端展示，Cloudflare 作为边缘计算、API 网关和**最终/摘要状态协调层**，Google Cloud Platform (GCP) 作为核心后端服务平台，负责主要的业务处理和详细状态记录。架构设计体现 Serverless、事件驱动（GCP Pub/Sub驱动GCP内部流程）、状态协调（Cloudflare DO负责最终/摘要状态）、可观测性（GCP Logging & Monitoring）等现代范式。

## ✅ 架构关键特性 (优雅优先调整)

- **Vercel 驱动的前端体验**：提供高性能、全球可达的用户界面，优秀的开发者体验。
- **Cloudflare 边缘加速与安全**：处理API请求，执行边缘逻辑，保障应用安全。
- **Cloudflare API 网关**：统一API入口，验证用户身份 (GCIP Token)，初始化Cloudflare DO记录任务，并将任务分发到GCP Pub/Sub。
- **Google Cloud Pub/Sub 驱动核心流程**：图片下载 → 元数据提取 → AI 处理等核心任务链由 Google Cloud Pub/Sub 的主题和订阅机制在**GCP内部驱动**，实现服务间的严格解耦和异步通信。
- **分层状态管理**:
    - **GCP Firestore (Native Mode) / Datastore**: 记录GCP内部各处理阶段的详细任务状态、进度和中间结果。
    - **Cloudflare Durable Object (DO)**：每个任务绑定一个 `TaskCoordinatorDO` 实例，负责管理任务的**最终或关键摘要状态**（如 `submitted`, `processing_in_gcp`, `completed`, `failed`），接收来自GCP流程完成后的**低频回调**，并作为边缘API查询状态的主要来源。
- **核心计算在 GCP**：主要的、可能较重的后端处理逻辑（如图片实际下载到GCS、元数据解析、AI模型调用）部署为 Google Cloud Functions 或 Cloud Run 服务，由 Pub/Sub 消息触发，并将详细状态写入GCP Firestore。
- **用户认证采用 GCP Identity Platform**：提供安全、可扩展的用户身份验证和管理方案。
- **数据邻近计算**: 核心处理过程中的主要对象数据（如待处理图片、中间产物）优先存储在 **Google Cloud Storage (GCS)**，以减少GCP计算服务的访问延迟。Cloudflare R2可选用于最终结果的边缘分发或缓存。
- **可观测性链路完整**：通过 TraceID贯穿全程，所有日志统一收集到 **Google Cloud Logging & Monitoring**。
- **结构化项目管理**：Monorepo + Turborepo，**GitHub/GitHub Actions**进行版本控制和CI/CD。
- **基础设施即代码 (IaC)**：使用 Terraform 统一管理 Cloudflare 和 GCP 的云资源。

## ✅ 核心架构构件 (优雅优先调整)

| 层级                 | 技术选型 (示例)                                                     | 职责                                                                                                                              |
| -------------------- | -------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| **前端展示层** | **Vercel** (例如 SvelteKit, Next.js 应用)                            | 用户配置输入界面、任务状态展示界面（主要查询DO中的摘要/最终状态）、图片搜索与结果查询界面。 |
| **CDN & 安全层** | Cloudflare                                                           | 全球内容分发网络 (CDN)、DDoS 防护、WAF、SSL/TLS 证书管理。                                                                        |
| **API 网关层** | Cloudflare Workers (`cf-worker-api-gateway`) | 统一 API 入口，路由，初步认证（验证 GCIP Token），初始化DO，发布初始任务消息到GCP Pub/Sub。                                                 |
| **状态协调层 (最终/摘要)** | Cloudflare Durable Objects (`TaskCoordinatorDO`, 例如 `cf-do-task-coordinator`) | 管理每个任务的**最终或关键摘要状态**。接收来自GCP核心流程完成后的回调。提供任务高级状态查询接口。                                                |
| **消息队列/事件总线 (GCP内部)** | **Google Cloud Pub/Sub** | 在GCP内部驱动核心任务链各阶段的异步解耦。例如：`new-task-topic` -> `download-topic` -> `metadata-topic` -> `ai-topic`。                    |
| **核心后端计算层 (GCP)** | **Google Cloud Functions / Cloud Run** (例如 `gcp-func-download-image`, `gcp-func-metadata-extract`) | 订阅 Pub/Sub 主题，执行具体的业务逻辑：图片下载(到GCS)、元数据提取、AI 分析与向量生成。将详细状态写入GCP Firestore。流程结束后回调CF DO。 |
| **用户认证服务** | **Google Cloud Identity Platform (GCIP)** | 用户注册、登录、密码管理、第三方 OAuth 登录、ID Token 生成与验证。                                                                              |
| **存储层** |                                                                      |                                                                                                                                 |
| &nbsp;&nbsp;对象存储 (主要) | **Google Cloud Storage (GCS)** / Cloudflare R2 (可选分发) | GCS作为GCP内部处理流程的主要对象存储。R2可选用于最终产物的边缘缓存或直接分发。                                                                    |
| &nbsp;&nbsp;结构化/NoSQL数据 (主要) | **GCP Firestore (Native Mode) / Datastore** / Cloudflare D1 (可选边缘) | GCP Firestore/Datastore存储GCP内部详细任务状态、用户配置等。D1可选用于边缘快速访问的摘要数据或DO关联数据。                                      |
| &nbsp;&nbsp;向量数据 | Cloudflare Vectorize / **GCP Vertex AI Vector Search (可选)** | 存储图片内容的向量嵌入，支持相似性搜索。                                                                                              |
| **可观测性层** | **Google Cloud Logging & Monitoring** (结合 `logger.ts`, `trace.ts`) | 收集、存储、分析和可视化来自 Vercel、Cloudflare 和 GCP 所有组件的日志与监控指标。                                                                  |
| **CI/CD 与代码管理** | **GitHub / GitHub Actions** | 源代码版本控制，自动化构建、测试、lint和多平台部署流程。                                                                                        |
| **基础设施管理** | Terraform                                                            | 以代码形式定义和管理 Cloudflare 和 GCP 上的所有云资源。                                                                            |