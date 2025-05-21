# 🔄 混合事件驱动与状态协调架构说明 (架构版本 2025年5月21日 - 优雅优先)

---

## 📦 架构背景

iN 项目为异步图像处理系统，核心流程包括：用户通过 Vercel 前端配置任务 -> Cloudflare API Gateway 接收请求并初始化 Cloudflare DO -> 任务在 GCP 后端通过一系列由 GCP Pub/Sub 驱动的服务处理（下载图片到GCS → 元数据提取 → AI 分析 → 存储）-> GCP 流程完成后回调 Cloudflare DO 更新最终/摘要状态 -> 结果可通过 API 查询展示。

在此架构中，需要：
- **GCP内部核心任务链的可靠异步推进与服务解耦**。
- **GCP内部各处理阶段详细状态的记录**。
- **Cloudflare DO 对任务最终/摘要状态的精确跟踪与协调，并作为边缘API查询的主要来源**。
- **旁路副作用任务（如增强日志、索引更新、通知等）能被异步触发和解耦处理**。

---

## 🎯 架构原则 (基于 GCP Pub/Sub 和 Cloudflare DO - 优雅优先)

> **核心任务链的各处理阶段在 GCP 内部通过 Google Cloud Pub/Sub 主题和订阅进行事件驱动和严格解耦。**
> **每个任务的详细处理过程状态记录在 GCP Firestore (Native Mode) / Datastore 中。**
> **每个任务的最终或关键摘要状态及其生命周期协调由 Cloudflare Durable Object (`TaskCoordinatorDO`) 精细管理，并减少跨云回调频率。**
> **旁路副作用任务可通过订阅 GCP Pub/Sub 的特定事件主题实现异步消费。**

---

## 🧱 实际实现结构

| 组件/机制                     | 技术/服务                                   | 描述与职责                                                                                                                                                                                            |
| ----------------------------- | ------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **用户交互与任务发起** | Vercel (前端) + Cloudflare Worker (API Gateway) | 用户通过 Vercel 界面配置并提交任务。API Gateway Worker 验证请求，初始化 `TaskCoordinatorDO` 记录任务高级状态（如 `submitted`），并将包含`taskId`的初始任务消息发布到 GCP Pub/Sub 的入口主题。 |
| **核心任务流程驱动 (GCP内部)** | **Google Cloud Pub/Sub** | 一系列 Pub/Sub 主题（如 `download-topic`, `metadata-topic`, `ai-topic`）和对应的订阅构成了GCP内部任务处理的主动脉。各阶段处理服务解耦，通过消息传递。                                    |
| **核心任务处理 (GCP)** | **GCP Cloud Functions / Cloud Run** | 作为 Pub/Sub 订阅者，执行具体的业务处理阶段（下载到GCS、元数据提取、AI分析）。将详细步骤状态和中间结果写入 GCP Firestore。处理完成后，向 Pub/Sub 的下一个主题发布消息。                         |
| **详细状态存储 (GCP)** | **GCP Firestore (Native Mode) / Datastore** | 存储 GCP 内部各处理阶段的详细任务状态、日志引用、中间处理结果等。                                                                                                                                   |
| **最终/摘要状态协调 (CF)** | Cloudflare Durable Object (`TaskCoordinatorDO`) | 每个任务对应一个 DO 实例。DO 记录任务的高级/摘要状态（`submitted`, `processing_in_gcp`, `completed`, `failed`）。**接收来自GCP核心流程最终完成或失败时的低频回调**。提供任务高级状态查询接口。 |
| **事件发布 (旁路)** | GCP Pub/Sub (特定业务事件主题)                 | 核心流程中的关键业务事件（如 `image.downloaded`, `metadata.extracted`, `ai.analyzed`, `task.completed`, `task.failed`）可以作为消息发布到专用的 Pub/Sub 主题，供其他非核心服务订阅。这些事件可由GCP核心处理服务或CF DO在适当时候发布。 |
| **事件订阅 (旁路)** | GCP Cloud Functions / Cloud Run (或其他服务)    | 订阅专用的 Pub/Sub 事件主题，实现异步的副作用逻辑，例如日志增强 (`gcp-func-log-enhancer`)、额外索引、通知等。                                                                          |
| **事件接口/结构** | `packages/shared-libs/events/types.ts` | 所有通过 Pub/Sub 传递的业务事件（消息体）应遵循统一的、在共享库中定义的结构 (例如 `INEvent<T, P>`)。                                                                       |
| **幂等与重试** | GCP Cloud Functions/Run + Pub/Sub             | 所有 Pub/Sub 消息的消费者 (GCP Functions/Run) 必须实现幂等处理。Pub/Sub 会自动处理消息的短期重试。                                                                                   |
| **死信处理** | GCP Pub/Sub (死信主题) + GCP Cloud Functions  | 无法成功处理的消息会被 Pub/Sub 自动转发到预先配置的死信主题，由专门的 Function 进行日志记录、告警或后续分析。                                                                             |

---

## 🧩 “插件”或旁路系统交互模式 (基于 Pub/Sub)

- **事件驱动**: 系统的扩展性主要通过增加新的 GCP Pub/Sub 主题和对应的订阅者 (GCP Functions/Run) 来实现。
- **松耦合**: 旁路逻辑（如日志增强、通知服务）与核心处理流程通过 Pub/Sub 完全解耦。它们只关心自己订阅的事件类型，不直接依赖核心服务的实现细节。
- **数据流**: 核心流程在GCP内部通过Pub/Sub串联，并将详细状态写入GCP Firestore。当GCP内部流程达到最终状态（或关键里程碑）时，一个GCP服务（可能是最后一个处理单元或一个专门的同步Function）会调用Cloudflare DO的API，以更新DO中存储的最终/摘要状态。Cloudflare的API Gateway主要从DO查询这个最终/摘要状态给前端。

---

## 📘 总结

通过 Vercel 提供前端，Cloudflare 提供边缘 API 和**最终/摘要状态协调** (DO)，GCP 提供核心后端计算 (Functions/Run)、强大的消息队列 (Pub/Sub)、**详细过程状态存储** (Firestore) 和身份认证 (GCIP)，iN 项目构建了一个职责清晰、松耦合、可扩展、可观测的现代多云事件驱动系统。该架构在追求优雅的同时，优化了跨云交互的频率，并充分利用了各平台的优势和免费资源，是实践现代软件工程范式的良好案例。