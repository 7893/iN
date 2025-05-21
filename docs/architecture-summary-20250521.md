# 🏗️ architecture-summary-20250521.md

iN 项目采用现代分布式多云架构，以 Vercel 提供前端展示，Cloudflare 作为边缘计算、API 网关和状态协调层，Google Cloud Platform (GCP) 作为核心后端服务平台。架构设计体现 Serverless、事件驱动（GCP Pub/Sub）、状态协调（Cloudflare DO）、可观测性（GCP Logging & Monitoring）等现代范式。

## ✅ 架构关键特性

- **Vercel 驱动的前端体验**：提供高性能、全球可达的用户界面，优秀的开发者体验。
- **Cloudflare 边缘加速与安全**：处理API请求，执行边缘逻辑（如认证预处理、请求转换），保障应用安全。
- **Cloudflare API 网关**：统一API入口，路由到 Cloudflare Workers 或间接触发 GCP 服务。
- **Google Cloud Pub/Sub 驱动核心流程**：图片下载 → 元数据提取 → AI 处理等核心任务链由 Google Cloud Pub/Sub 的主题和订阅机制驱动，实现服务间的严格解耦和异步通信。
- **状态管理采用 Cloudflare Durable Object (DO)**：每个任务绑定一个 `TaskCoordinatorDO` 实例，支持任务生命周期的状态记录、幂等更新与可追踪查询。
- **核心计算在 GCP**：主要的、可能较重的后端处理逻辑（如图片实际下载、元数据解析、AI模型调用）部署为 Google Cloud Functions 或 Cloud Run 服务，由 Pub/Sub 消息触发。
- **用户认证采用 GCP Identity Platform**：提供安全、可扩展的用户身份验证和管理方案，支持多种登录方式。
- **可观测性链路完整**：通过 TraceID（在 Cloudflare Worker 和 GCP 服务间传递）贯穿全程，所有日志（包括 Vercel 前端、Cloudflare 服务、GCP 服务）统一推送或收集到 **Google Cloud Logging & Monitoring**，提供实时监控、分析和告警。
- **结构化项目管理**：继续使用 Monorepo + Turborepo 管理前后端、Worker、GCP Functions/Run、基础设施代码与共享库。**GitHub** 进行版本控制，**GitHub Actions** 实现 CI/CD 自动化。
- **基础设施即代码 (IaC)**：使用 Terraform 统一管理 Cloudflare 和 GCP 的云资源。

## ✅ 核心架构构件

| 层级                 | 技术选型 (示例)                                                     | 职责                                                                         |
| -------------------- | -------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| **前端展示层** | **Vercel** (例如 SvelteKit, Next.js 应用)                            | 用户配置输入界面、任务状态展示界面、图片搜索与结果查询界面。                 |
| **CDN & 安全层** | Cloudflare                                                           | 全球内容分发网络 (CDN)、DDoS 防护、WAF、SSL/TLS 证书管理。                       |
| **API 网关层** | Cloudflare Workers (`iN-worker-A-api-gateway-20250402`) | 统一 API 入口，请求路由，初步认证（如验证 GCIP Token），限流，日志记录。         |
| **状态协调层** | Cloudflare Durable Objects (`TaskCoordinatorDO`) | 管理每个任务的详细状态机，记录处理阶段、结果、错误信息。被各处理阶段回调更新。 |
| **消息队列/事件总线** | **Google Cloud Pub/Sub** | 实现核心任务链各阶段的异步解耦。例如：`new-task-topic` -> `download-topic` -> `metadata-topic` -> `ai-topic`。 |
| **核心后端计算层** | **Google Cloud Functions / Cloud Run** | 订阅 Pub/Sub 主题，执行具体的业务逻辑：图片下载、元数据提取、AI 分析与向量生成。 |
| **用户认证服务** | **Google Cloud Identity Platform (GCIP)** | 用户注册、登录、密码管理、第三方 OAuth 登录、ID Token 生成与验证。              |
| **存储层** |                                                                      |                                                                              |
| &nbsp;&nbsp;对象存储 | Cloudflare R2 / **Google Cloud Storage (GCS)** | 存储原始图片、处理后的图片、其他大型二进制文件。                        |
| &nbsp;&nbsp;结构化数据 | Cloudflare D1 / **GCP Firestore (Native Mode) / Datastore** | 存储任务元数据、AI 分析结果摘要、用户配置（原Firebase Firestore部分）。 |
| &nbsp;&nbsp;向量数据 | Cloudflare Vectorize / **GCP Vertex AI Vector Search (可选)** | 存储图片内容的向量嵌入，支持相似性搜索。                          |
| **可观测性层** | **Google Cloud Logging & Monitoring** (结合 `logger.ts`, `trace.ts`) | 收集、存储、分析和可视化来自 Vercel、Cloudflare 和 GCP 所有组件的日志与监控指标。  |
| **CI/CD 与代码管理** | **GitHub / GitHub Actions** | 源代码版本控制，自动化构建、测试、lint和多平台部署流程。                          |
| **基础设施管理** | Terraform                                                            | 以代码形式定义和管理 Cloudflare 和 GCP 上的所有云资源。                           |