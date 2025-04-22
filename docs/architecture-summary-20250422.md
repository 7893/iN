# 🏗️ architecture-summary-20250422.md

iN 项目采用现代分布式异步架构，基于 Cloudflare 栈为核心，并辅以 Vercel 和 Firebase 提供边缘展示与认证服务，架构设计体现 Serverless、事件驱动、状态协调、可观测性等现代范式。

## ✅ 架构关键特性

- **异步队列驱动主链流程**：图片下载 → 元数据 → AI 处理由 Cloudflare Queues 驱动，严格解耦。
- **状态管理采用 Durable Object（DO）**：每个任务绑定一个 DO 实例，支持状态幂等更新与可追踪。
- **可观测性链路完整**：TraceID 全程贯穿，Logpush 推送至 Axiom，提供实时监控。
- **结构化项目管理**：Monorepo + Turborepo 管理前后端、Worker、Infra 与共享库。
- **安全体系分层清晰**：用户层采用 Firebase Auth，内部服务使用 HMAC/JWT 签名校验。

## ✅ 核心架构构件

| 层级 | 技术 | 职责 |
|------|------|------|
| 前端展示 | Vercel + Cloudflare Pages | 配置输入、任务查看、搜索查询 |
| API 层 | Workers A/B/G/H/I/J | 网关 + 任务配置 + 数据查询接口 |
| 核心流程 | Workers C/D/E/F + DO + Queues | 图片处理主流程 |
| 存储层 | R2, D1, Vectorize | 原图 + 元数据 + 向量数据存储 |
| 状态协调 | TaskCoordinatorDO | 任务状态状态机 |
| 日志链路 | logger.ts + trace.ts + Axiom | 可追踪结构化日志 |

---

文档名：architecture-summary-20250422.md  
更新日期：2025-04-22
