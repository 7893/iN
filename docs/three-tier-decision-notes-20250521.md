# 🧠 多元平台选型与职责划分决策记录 (架构版本 2025年5月21日)

---

## 🎯 背景

原始架构设想主要围绕 Cloudflare 单栈或 Cloudflare + Firebase + Vercel 的组合。为进一步优化功能、成本（最大化利用永久免费资源）、提升开发体验并利用各平台特定优势，现转为以 **Vercel (前端) + Cloudflare (边缘层/API网关/状态协调) + Google Cloud Platform (GCP, 核心后端服务)** 的“现代多元分布式架构”。GitHub 用于代码托管和 CI/CD。

---

## 🧩 多元平台划分

| 平台                 | 核心职责                                                     | 使用组件 (示例)                                                                                                                               |
| -------------------- | ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------- |
| 🎨 **Vercel** | 前端托管、全球分发与用户交互界面                               | Hosting (Hobby Plan), Preview Deployments, Edge Functions (可选，但主要后端API在Cloudflare/GCP)。                                                 |
| ☁️ **Cloudflare** | API网关、边缘逻辑、分布式状态协调、部分边缘存储、安全防护         | Workers, Durable Objects, R2, D1, Vectorize, CDN, Security (WAF, DDoS)。                                                                        |
| 🚀 **Google Cloud Platform (GCP)** | 核心后端计算、消息队列、用户认证、核心数据存储（NoSQL/SQL可选）、日志监控 | Cloud Functions/Run, Pub/Sub, Identity Platform, Firestore (Native Mode)/Datastore, Cloud Storage (GCS), Cloud SQL (可选), Vertex AI (可选), Logging & Monitoring。 |
| GITHUB"> **GitHub** | 代码版本控制、协作、自动化CI/CD流程                          | Repositories, GitHub Actions。                                                                                                              |

---

## ✅ 决策依据

- **Vercel**：作为前端首选，提供卓越的开发体验（DX）、快速的构建与部署、强大的全球 CDN 和易用的预览环境，其 Hobby Plan（免费套餐）能很好地满足个人项目需求。
- **Cloudflare**：作为API网关、边缘计算层和安全屏障，处理用户流量入口，执行轻量级边缘逻辑；Durable Objects 用于任务状态的精细化协调，具有独特的分布式状态管理能力；R2/D1/Vectorize 提供低延迟的边缘存储方案，且均有可观的免费额度。
- **Google Cloud Platform (GCP)**：承载核心的、可能较重的后端处理逻辑（通过 Cloud Functions/Run），利用 Pub/Sub 实现健壮的异步消息传递和微服务解耦，通过 Identity Platform 提供强大且免费额度高的用户认证，通过 Firestore/Datastore 提供灵活且免费额度高的NoSQL存储，并使用其 Logging & Monitoring 服务进行统一的可观测性管理。GCP 的永久免费套餐在这些核心后端服务上非常有吸引力。
- **GitHub**：作为业界领先的代码托管和协作平台，其 Actions 功能提供了强大且免费额度充足的 CI/CD 能力，便于实现多平台部署的自动化。

---

## 📌 使用策略总结

- **Vercel** 专注前端，提供最佳用户界面体验和部署流程。
- **Cloudflare** 专注边缘能力：作为流量入口 (API Gateway Worker)，执行安全策略，运行轻量级边缘逻辑，并通过 Durable Objects 进行分布式有状态协调。边缘存储 (R2, D1, Vectorize) 用于快速数据访问。
- **GCP** 专注核心后端服务：通过 Pub/Sub 驱动异步任务，Cloud Functions/Run 执行主要业务处理，Identity Platform 管理用户身份，Firestore/Datastore (或可选的 Cloud SQL/GCS) 作为核心数据持久化层，Cloud Logging/Monitoring 统一日志。
- **GitHub** 专注开发运维：作为所有代码的单一来源和自动化构建、测试、部署的驱动核心。
- **服务间通信**：
    - 前端 (Vercel) 与后端通过 Cloudflare API Gateway Worker 通信。
    * Cloudflare 服务与 GCP 服务间通过安全的 API 调用（例如，Worker 调用 Pub/Sub API 或 Cloud Function HTTP 触发器），需妥善管理认证凭据。
- **成本控制**：严格监控各平台免费额度的使用情况，设计上优先选用免费额度内的服务和配置。
- **基础设施管理**：使用 Terraform 统一管理 Cloudflare 和 GCP 的基础设施资源，由 GitHub Actions 驱动执行。

---

## 💡 经验结论 (预期)

- 通过此多元平台组合，可以充分利用各服务商的优势和免费资源，在功能、性能、开发效率和成本之间取得良好平衡。
- 职责边界清晰，有助于独立开发和维护各部分。
- 体验和实践了现代多云Serverless架构，是个人项目、中小型分布式系统或教育型架构演示项目的理想选择。