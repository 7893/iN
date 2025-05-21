# 🔄 混合事件驱动架构说明 (架构版本 2025年5月21日)

---

## 📦 架构背景

iN 项目为异步图像处理系统，核心流程包括：用户通过 Vercel 前端配置任务 -> Cloudflare API Gateway 接收请求 -> 任务在 GCP 后端通过一系列服务处理（下载图片 → 元数据提取 → AI 分析 → 存储）-> 结果可通过 API 查询展示。

在此架构中，需要：
- **核心任务链的可靠异步推进与服务解耦**。
- **任务状态的精确跟踪与协调**。
- **旁路副作用任务（如增强日志、索引更新、通知等）能被异步触发和解耦处理**。

---

## 🎯 架构原则 (基于 GCP Pub/Sub 和 Cloudflare DO)

> **核心任务链使用 Google Cloud Pub/Sub 主题和订阅进行事件驱动和严格解耦。**
> **每个任务的详细状态和生命周期协调由 Cloudflare Durable Object (TaskCoordinatorDO) 精细管理。**
> **旁路副作用任务可通过订阅 Pub/Sub 的特定主题（或由 DO/核心服务直接触发）实现异步消费。**

---

## 🧱 实际实现结构

| 组件/机制             | 技术/服务                                   | 描述与职责                                                                                                                               |
| --------------------- | ------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| **用户交互与任务发起** | Vercel (前端) + Cloudflare Worker (API Gateway) | 用户通过 Vercel 界面配置并提交任务。API Gateway Worker 验证请求，初始化 `TaskCoordinatorDO` 记录任务，并将初始任务消息发布到 GCP Pub/Sub 的入口主题。 |
| **核心任务流程驱动** | **Google Cloud Pub/Sub** | 一系列 Pub/Sub 主题（如 `download-topic`, `metadata-topic`, `ai-topic`）和对应的订阅构成了任务处理的主动脉。各阶段处理服务解耦，通过消息传递。     |
| **核心任务处理** | **GCP Cloud Functions / Cloud Run** | 作为 Pub/Sub 订阅者，执行具体的业务处理阶段（下载、元数据、AI）。处理完成后，向 Pub/Sub 的下一个主题发布消息，并回调 `TaskCoordinatorDO` 更新状态。 |
| **任务状态协调** | Cloudflare Durable Object (`TaskCoordinatorDO`) | 每个任务对应一个 DO 实例。DO 记录任务的详细状态、各阶段结果、错误信息。接收来自 GCP 处理服务的状态更新回调。提供任务状态查询接口。                     |
| **事件发布 (旁路)** | GCP Pub/Sub (特定主题) / DO 或核心服务直接调用 | 核心流程中的关键事件（如 `image.downloaded`, `metadata.extracted`, `ai.analyzed`）可以作为消息发布到专用的 Pub/Sub 主题，供其他非核心服务订阅。或者，`TaskCoordinatorDO` 或核心处理服务在完成特定步骤后，直接异步调用旁路服务。 |
| **事件订阅 (旁路)** | GCP Cloud Functions / Cloud Run (或其他服务)    | 订阅专用的 Pub/Sub 事件主题，实现异步的副作用逻辑，例如日志增强、额外索引、通知等。例如，一个 `log-enhancer-function`。 |
| **事件接口/结构** | `shared-libs/events/` (类型定义) | 所有通过 Pub/Sub 传递的业务事件（消息体）应遵循统一的、在共享库中定义的结构 (例如 `INEvent<T>`)。                                     |
| **幂等与重试** | GCP Cloud Functions/Run + Pub/Sub             | 所有 Pub/Sub 消息的消费者 (GCP Functions/Run) 必须实现幂等处理，因为 Pub/Sub 保证至少一次消息传递。Pub/Sub 会自动处理消息的短期重试。           |
| **死信处理** | GCP Pub/Sub (死信主题) + GCP Cloud Functions  | 无法成功处理的消息会被 Pub/Sub 自动转发到预先配置的死信主题，由专门的 Function 进行日志记录、告警或后续分析。                                 |

---

## 🧩 “插件”或旁路系统简化说明 (基于 Pub/Sub)

- **事件驱动**: 系统的扩展性主要通过增加新的 Pub/Sub 主题和订阅者 (GCP Functions/Run) 来实现。
- **松耦合**: 旁路逻辑（如日志增强、通知服务）与核心处理流程通过 Pub/Sub 完全解耦。它们只关心自己订阅的事件类型，不直接依赖核心服务的实现细节。
- **示例**: `log-enhancer-function` 可以订阅一个包含所有阶段性成果事件的 Pub/Sub 主题，消费这些事件并生成更丰富的、聚合的日志记录到 Google Cloud Logging。

---

## 📘 总结

通过 Vercel 提供前端，Cloudflare 提供边缘 API 和状态协调 (DO)，GCP 提供核心后端计算 (Functions/Run)、强大的消息队列 (Pub/Sub) 和身份认证 (GCIP)，iN 项目构建了一个职责清晰、松耦合、可扩展、可观测的现代多云事件驱动系统。该架构充分利用了各平台的优势和免费资源，是实践现代软件工程范式的良好案例。