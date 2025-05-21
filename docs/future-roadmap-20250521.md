# 🚧 future-roadmap-20250521.md (架构版本 2025年5月21日)

## 📍 收敛式演进路线图

本项目为单人架构实验项目，核心目标是实践现代多云 Serverless 工程范式与关键能力落地，非商业化系统。当前架构（Vercel 前端 + Cloudflare 边缘 + GCP 核心后端）为 MVP 阶段奠定了基础。

在已有架构基础上，完成 MVP 后，后续可考虑推进以下少量高价值收敛性演进：

---

## 🧠 向量搜索 (Vectorize) 增强

- **当前状态**: MVP 计划接入 Cloudflare Vectorize 或 GCP Vertex AI Vector Search 进行基本的文本向量查询。
- **后续演进**:
    - **以图搜图**: 实现基于上传图片或指定图片URL进行相似图片搜索的功能。
    - **多模态搜索**: 探索结合文本与图像特征进行更复杂的多模态搜索。
    - **结果优化**: 引入更高级的排序算法和过滤条件，优化搜索结果的相关性和用户体验。
    - **性能与成本**: 监控向量数据库的性能和成本，根据用量选择或优化 Cloudflare Vectorize 与 GCP Vertex AI Vector Search 的配置。

## 📊 状态展示与用户体验优化

- **当前状态**: MVP 完成基本任务状态 API (Cloudflare Worker 调用 DO) 和前端展示。
- **后续演进**:
    - **实时/准实时状态更新**: 研究使用 WebSocket (可通过 Cloudflare Workers 实现) 或前端轮询优化（如基于 HTTP 长轮询或 Exponential Backoff）来提供更实时的任务状态更新。
    * **更详细的错误提示与指引**: 当任务失败时，在前端向用户展示更友好、更具体的错误信息和可能的解决方案。
    * **用户任务管理界面增强**: 增加更丰富的筛选、排序、批量操作等功能。

## ☑️ GCP Pub/Sub 死信主题 (DLT) 深度处理与自动化

- **当前状态**: MVP 实现 GCP Pub/Sub DLT 基础配置、日志记录和告警。
- **后续演进**:
    - **自动化重试特定错误**: 针对 DLT 中可识别的、因瞬时问题导致的失败消息，开发专门的 GCP Cloud Function 尝试有条件地自动重试。
    * **失败模式分析与归档**: 定期分析 DLT 中的消息，识别常见的失败模式以改进主流程。将长时间未处理或无法重试的死信消息从 DLT 归档到 Google Cloud Storage (GCS) 进行长期存储和审计。
    * **DLT 管理界面 (可选)**: 构建简单的内部工具查看和管理 DLT 中的消息。

## 🧩 事件驱动旁路逻辑扩展 (基于 GCP Pub/Sub)

- **当前状态**: MVP 阶段主要关注核心处理链。已有一个日志增强订阅者（GCP Cloud Function）的示例概念。
- **后续演进**:
    * **通知服务**: 开发 GCP Cloud Function 订阅特定的业务事件主题 (例如 `task.completed`, `task.failed`)，并通过邮件、Slack 或其他渠道向用户或管理员发送通知。
    * **数据聚合与分析**: 开发 GCP Cloud Function 将关键业务事件或处理结果输出到 BigQuery 或其他分析服务，进行运营数据分析。
    * **Webhook 集成**: 允许第三方服务通过安全的 Webhook 订阅 iN 项目产生的特定事件。

## 🚀 部署与运维优化 (GitHub Actions, Terraform)

- **Canary /蓝绿部署**: 探索使用 GitHub Actions 配合 Cloudflare Workers/GCP Cloud Run 的流量切换功能，实现更平滑、风险更低的生产环境部署策略。
- **成本监控与优化**: 持续监控 Vercel, Cloudflare, GCP 各项服务的费用，并根据实际用量优化资源配置，确保最大化利用免费额度，控制潜在成本。
- **IaC 覆盖率提升**: 使用 Terraform 管理更多细粒度的 Cloudflare 和 GCP 资源配置。

## 🔐 安全性增强

- **定期安全审计**: 对 GCIP 配置、Cloudflare 安全规则、GCP IAM 策略、服务账号权限等进行定期审查。
- **依赖项安全扫描**: 持续集成 Dependabot 或类似工具，自动检测和更新存在安全漏洞的第三方依赖。
- **输入验证强化**: 对所有 API 入口和 Pub/Sub 消息消费者进行更全面的输入验证和边界条件测试。

---

文档名：future-roadmap-20250521.md (原 future-roadmap-20250422.md)
更新日期：2025-05-21