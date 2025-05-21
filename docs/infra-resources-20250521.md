# 📦 iN 项目基础设施资源清单 (摘要 - 架构版本 2025年5月21日)

本文档简要列出 iN 项目在 Vercel, Cloudflare, 和 Google Cloud Platform (GCP) 上使用的核心基础设施资源。详细清单请参见 `infra-resources-detailed-20250521.md`。

---

## 🎨 Vercel (前端平台)

- **前端应用项目**: 托管例如 SvelteKit/Next.js 构建的用户界面。
    - 利用 Hobby Plan (免费套餐) 进行构建、部署和全球 CDN 分发。
- **环境变量**: 管理前端应用连接后端 API 和认证服务所需的配置。

---

## ☁️ Cloudflare (边缘网络、API网关、状态协调与边缘存储)

- **Workers**:
    - **API Gateway Worker**: 统一 API 入口，路由，认证预处理。
    - (可选) **Frontend Serving Worker**: 如果选择用 Worker 服务前端静态资源 (从R2)。
    - 其他轻量级边缘逻辑 Worker。
- **Durable Objects**:
    - **TaskCoordinatorDO**: 任务状态协调器，管理任务生命周期。
- **R2 Bucket**: 存储图像原图、处理结果、(可选)前端静态资源。
- **D1 数据库**: 存储结构化元数据、任务记录摘要。
- **Vectorize Index**: 存储图像向量嵌入，支持相似性搜索。
- **(可选) KV 命名空间**: 缓存少量配置。
- **Logpush 配置**: 将 Cloudflare 日志导出到 GCP。

---

## 🚀 Google Cloud Platform (GCP) (核心后端服务)

- **Identity Platform (GCIP)**: 用户身份认证和管理。
- **Pub/Sub**:
    - **主题 (Topics)**: 用于各处理阶段的异步消息传递 (例如 `new-task`, `download-requests`, `metadata-requests`, `ai-requests`, `business-events`, 死信主题等)。
    - **订阅 (Subscriptions)**: Cloud Functions/Run 服务通过订阅来消费消息。
- **Cloud Functions / Cloud Run**: Serverless 计算服务，执行核心业务逻辑（下载、元数据、AI分析、日志增强等），由 Pub/Sub 触发。
- **Firestore (Native Mode) / Datastore**: NoSQL 数据库，存储用户配置、应用设置、部分任务元数据。
- **Cloud Storage (GCS) (可选)**: 对象存储，可作为 R2 补充/替代，或用于日志归档。
- **Vertex AI Vector Search (可选)**: 高级向量搜索，可作为 Cloudflare Vectorize 的补充/替代。
- **Cloud Logging & Monitoring**: 集中收集、分析和可视化所有服务日志与监控指标，配置告警。
- **Service Accounts & IAM**: 管理服务间访问权限。
- **Secret Manager (可选)**: 存储GCP服务运行时需要的敏感凭证。

---

## GITHUB"> GitHub (代码管理与 CI/CD)

- **Repository**: 主代码仓库 (Monorepo)。
- **GitHub Actions**: CI/CD 工作流，自动化测试、构建、部署到 Vercel, Cloudflare, GCP。
- **Actions Secrets**: 存储部署所需的敏感凭证。

---

所有基础设施资源优先考虑利用各服务商提供的永久免费额度。