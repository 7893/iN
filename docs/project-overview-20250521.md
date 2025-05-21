# 🌍 iN 项目总览 (架构版本 2025年5月21日)
📄 文档名称：project-overview-20250521.md (原 project-overview-20250422.md)
🗓️ 更新时间：2025-05-21

---

## 🚀 项目使命与愿景

iN 项目旨在构建一个现代化的、基于多云 Serverless 架构的智能图像处理与索引系统。它不仅仅是一个功能性的应用，更是一个探索和实践前沿软件工程范式的平台，包括事件驱动架构、分布式状态协调、基础设施即代码、全面的可观测性以及AI辅助开发。

**愿景**：成为一个清晰、可复用、高度自动化的多云 Serverless 架构蓝本，为个人开发者、小型团队或教育目的提供有价值的参考和起点，并优先利用各云服务商的永久免费资源。

## ✨ 核心特性 (基于新架构)

- **多云协同**: 优雅地结合 Vercel (前端), Cloudflare (边缘计算、API网关、安全、状态协调、边缘存储) 和 Google Cloud Platform (GCP) (核心后端计算、消息队列、用户认证、核心数据存储、日志监控) 的优势，最大化利用各平台的永久免费资源。
- **Serverless 计算**: 大部分计算任务由 Cloudflare Workers, GCP Cloud Functions, GCP Cloud Run 等 Serverless 服务承载，实现按需伸缩和成本优化。
- **事件驱动核心**: 后端核心处理流程通过 GCP Pub/Sub 进行异步解耦，提高系统的弹性和可扩展性。
- **精细化状态管理**: Cloudflare Durable Objects (`TaskCoordinatorDO`) 为每个图像处理任务提供强一致性的状态跟踪和生命周期管理。
- **现代化前端体验**: Vercel 平台提供高性能、易于开发和部署的前端用户界面。
- **强大的用户认证**: GCP Identity Platform 提供安全可靠的用户身份验证解决方案。
- **全面的可观测性**: 结构化日志贯穿所有服务，统一汇聚到 GCP Cloud Logging & Monitoring，实现端到端追踪、分析和告警。
- **基础设施即代码 (IaC)**: Cloudflare 和 GCP 的基础设施资源通过 Terraform 进行声明式管理和版本控制。
- **自动化CI/CD**: 使用 GitHub 和 GitHub Actions 实现从代码提交到多平台部署的全自动化流程。
- **AI辅助开发**: 项目的设计、文档和部分代码的生成过程积极采用生成式AI工具，探索人机协作的新模式。

## 🛠️ 技术栈概览 (架构版本 2025年5月21日)

- **前端**: Vercel (SvelteKit/Next.js 或其他现代框架)
- **边缘与API网关**: Cloudflare Workers, Durable Objects
- **边缘存储**: Cloudflare R2 (对象), D1 (结构化), Vectorize (向量)
- **核心后端计算**: GCP Cloud Functions, GCP Cloud Run
- **消息队列**: GCP Pub/Sub
- **用户认证**: GCP Identity Platform (GCIP)
- **核心数据库**: GCP Firestore (Native Mode) / Datastore (NoSQL), (可选) GCP Cloud SQL
- **对象存储 (核心/备份)**: (可选) GCP Cloud Storage (GCS)
- **向量搜索 (核心/高级)**: (可选) GCP Vertex AI Vector Search
- **日志与监控**: GCP Cloud Logging & Monitoring
- **代码管理与CI/CD**: GitHub & GitHub Actions
- **基础设施管理**: Terraform
- **开发语言**: TypeScript
- **包管理**: pnpm + Turborepo (Monorepo)

## 🌟 项目价值与预期成果

- **技术实践平台**: 为开发者提供一个真实的多云Serverless项目案例，用于学习和实践现代架构。
- **可复用组件与模式**: 项目中的部分模块（如事件模式、共享库、IaC模块）可以被其他项目借鉴或复用。
- **成本效益**: 优先使用永久免费资源，为个人项目和初创团队提供低成本启动方案。
- **AI辅助工程探索**: 展示AI工具在软件开发生命周期中的应用潜力。
- **文档驱动开发**: 强调清晰、及时、与架构一致的文档的重要性。

## 🎯 当前状态 (概念性，基于 `project-overview-20250422.md`)

- 新的 Vercel + Cloudflare + GCP 多云架构和命名体系已完成设计。
- 核心资源已通过 Terraform 进行规划（待具体编码）。
- 核心流程（前端触发 -> CF API -> CF DO -> GCP Pub/Sub -> GCP 计算 -> CF DO 回调）已明确。
- 以最大化利用免费资源为目标的服务选型已完成。

## 下一步

请参考 `docs/phased-implementation-*.md` 和 `docs/action-checklist-*.md` 了解项目的具体实施计划和当前任务。

我们致力于将 iN 项目打造成一个高质量的开源架构范例。