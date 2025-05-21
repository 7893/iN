# 🚀 iN 项目 MVP 实现清单 (架构版本 2025年5月21日)
📄 文档名称：mvp-manifest-20250521.md (原 mvp-manifest-20250422.md)
🗓️ 更新时间：2025-05-21

---

## 🎯 最小可行产品 (MVP) 目标

构建一个**完整闭环的、基于多云 Serverless 架构的图像处理与索引系统**，包括通过 Vercel 前端进行任务配置与结果展示，Cloudflare 作为 API 网关和边缘协调，GCP 作为核心后端处理和数据服务。MVP 需体现核心架构（事件驱动、状态协调、可观测性）与主要工程范式。

---

## ✅ MVP 核心功能点

| 模块/功能             | 描述                                                                                                | 核心技术/服务                                                                                               | 状态     | 备注 (参考原 `mvp-manifest-20250422.md`) |
| --------------------- | --------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- | -------- | -------------------------------------------------- |
| **用户认证** | 用户可以通过 GCIP 支持的方式 (如 Google/GitHub OAuth) 登录系统。                                      | Vercel (前端集成 GCIP SDK), GCP Identity Platform (GCIP)                                                      | 计划中   | 替换原 Firebase Auth 方案。                            |
| **图片任务配置与提交** | 用户通过 Vercel 前端界面配置图片来源 (如 URL) 和处理选项，并发起任务。                                  | Vercel (前端表单), Cloudflare Worker (API Gateway)                                                            | 计划中   | API GW 验证 GCIP Token, 初始化 DO, 发布到 Pub/Sub。    |
| **图片采集** | 后端服务从指定 URL 下载图片，并存入对象存储。                                                         | GCP Pub/Sub (任务消息), GCP Cloud Function/Run (下载逻辑), Cloudflare R2 / GCP GCS (图片存储)               | 计划中   | Worker D 的功能迁移到 GCP。                              |
| **元数据提取** | 从下载的图片中提取基础元数据 (尺寸、格式等)。                                                         | GCP Pub/Sub, GCP Cloud Function/Run (提取逻辑), Cloudflare D1 / GCP Firestore (元数据存储)                      | 计划中   | Worker E 的功能迁移到 GCP。                              |
| **AI 分析与向量生成** | 对图片进行 AI 内容分析，提取标签，生成向量嵌入。                                                      | GCP Pub/Sub, GCP Cloud Function/Run (AI分析逻辑, 可能调用外部AI或Vertex AI), Cloudflare Vectorize / GCP Vertex AI Vector Search (向量存储) | 计划中   | Worker F 的功能迁移到 GCP。                              |
| **任务状态管理与协调** | `TaskCoordinatorDO` 跟踪每个任务的处理阶段、状态和结果。                                            | Cloudflare Durable Object (TaskCoordinatorDO)                                                               | 计划中   | DO 接收来自 GCP Functions/Run 的状态回调。                 |
| **任务状态查询** | 用户可以通过 Vercel 前端查询已提交任务的当前状态和处理结果。                                            | Vercel (前端界面), Cloudflare Worker (API Gateway 调用 DO)                                                      | 计划中   | 原 Worker H 的功能。                                   |
| **(可选) 向量搜索接口** | 提供基础的API接口，允许通过文本描述搜索相似图片。                                                     | Cloudflare Worker (API), Cloudflare Vectorize / GCP Vertex AI Vector Search                                   | 🟡 待定   | MVP 后期或后续迭代。                                   |
| **前端配置页面** | Vercel 前端提供用户界面，用于登录、任务配置、发起任务。                                                 | Vercel (SvelteKit/Next.js)                                                                                  | 计划中   | 原 `/config` 页面功能。                         |
| **前端状态追踪页面** | Vercel 前端提供用户界面，展示任务列表、各任务的处理状态和最终结果。                                     | Vercel (SvelteKit/Next.js)                                                                                  | 计划中   | 原状态追踪页面功能。                           |
| **日志与可观测性基础** | 结构化日志输出，`traceId` 传递，日志集中到 GCP Logging，基础的 Pub/Sub 死信主题监控与告警。           | Cloudflare Workers, GCP Cloud Functions/Run, GCP Pub/Sub, GCP Logging & Monitoring                          | 计划中   |                                                    |
| **CI/CD 基础流程** | GitHub Actions 实现代码 Lint, Test, Build, 并能部署到 Vercel, Cloudflare, GCP 的开发/预览环境。 | GitHub Actions, Terraform (基础配置)                                                                        | 计划中   |                                                    |

---

## 🧪 测试与部署 (MVP阶段)

- ✅ **单元测试**: 共享库 (`packages/shared-libs`) 及各核心逻辑模块 (CF Workers, GCP Functions) 具备基本的单元测试 (Vitest)。
- ✅ **CI/CD**: GitHub Actions 执行 Lint/Test/Build 流程。
- ✅ **本地开发与模拟**:
    - Vercel CLI 本地运行前端。
    - Wrangler CLI 本地运行 Cloudflare Workers/DO。
    - GCP SDK 及模拟器 (Pub/Sub, Firestore, Functions Framework) 本地运行 GCP 服务。
- ✅ **基础设施即代码 (IaC)**: Cloudflare 和 GCP 的核心资源通过 Terraform 定义和管理，能通过 GitHub Actions 进行 Plan/Apply。

---

## 📘 MVP 定义成功原则 (基于 `mvp-manifest-20250422.md` 并调整)

> 满足以下条件即可认定为 MVP 完成：
> - **核心链路完整闭环**: 从 Vercel 前端发起任务 -> Cloudflare API Gateway -> GCP Pub/Sub -> GCP Cloud Functions/Run (下载→元数据→AI) -> 数据存储 (R2/GCS, D1/Firestore, Vectorize/Vertex AI) -> 状态更新回 Cloudflare DO -> 前端可查询到最终状态和基本结果。
> - **用户认证可用**: 用户可以通过 GCIP 登录并使用系统核心功能。
> - **配置与查询可用**: 前端提供基本的任务配置界面和结果状态查询界面。
> - **API 可追踪**: Cloudflare API Gateway 和 GCP 后端服务间的调用包含 `traceId`，日志在 GCP Logging 中可查。
> - **部署与测试流程通顺**: 代码可通过 GitHub Actions 部署到各平台（至少是开发/预览环境），基础单元测试和CI流程正常运行。
> - **资源可管控**: 核心云资源由 Terraform 管理。
> - **免费额度优先**: 所有选用的服务和配置优先考虑在其永久免费额度内运行。

---
文件名：mvp-manifest-20250521.md (原 mvp-manifest-20250422.md)
更新日期：2025-05-21