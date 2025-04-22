# 📐 iN Architecture Summary  
📄 文档名称：architecture-summary-20250422.md  
🗓️ 更新时间：2025-04-22

---

## 📌 项目定位

**iN (Intelligent Images Infrastructure Network)** 是一个用于实验现代工程范式的分布式图像智能处理系统，涵盖从图像采集到 AI 分析再到前端展示的完整流程，融合了边缘计算、Serverless 架构、事件驱动、函数式编程等特性。

---

## 🧱 核心架构层级

| 层级 | 组件 | 描述 |
|------|------|------|
| ⬆️ 前端呈现 | Vercel + SvelteKit (SPA) | 提供任务配置、任务状态展示、图像结果渲染、搜索等功能 |
| ⚙️ API 接口 | Cloudflare Workers A/B/G/H | 统一 API 接入层，负责认证、路由、配置/任务状态查询 |
| 🔁 异步主链 | Workers C/D/E/F + Durable Object | 下载 → 元数据 → AI，强一致性状态机协作控制 |
| 📦 存储层 | R2, D1, Vectorize, KV | 存储图片原图、元数据、配置、向量等 |
| 🔒 认证层 | Firebase Auth + HMAC/JWT | 支持用户登录与 API 级认证，集中密钥管理 |
| 📊 可观测性层 | Logpush + Axiom + TraceID | 实现日志聚合与链路追踪、异常告警等 |
| 🛠️ 基础设施 | Terraform + GitLab CI | 管理所有资源与密钥，自动化部署流程支持中 |

---

## 🌀 架构范式集成概览

- 混合事件驱动架构（Hybrid EDA）
- 函数式副作用封装（logger, trace, task）
- 状态机控制（Durable Object）
- 可观测性全链追踪（traceId + Axiom）
- 安全与幂等机制（Secrets + Idempotent Queue Consumers）
- 基础设施即代码（Terraform 全覆盖）

---

## 🧱 资源命名与部署结构

- 所有资源统一命名：`in-<类型>-<编号>-<功能>-<日期>`
- 所有 Worker 独立部署，配置统一写入 wrangler.toml 与 terraform
- 前端部署在 Vercel，后端完全在 Cloudflare，用户信息在 Firebase

---

## 🧩 未来可扩展性

- 插件系统（事件订阅者）
- 多租户支持（按 tenantId 分区 D1）
- 向量推荐与智能搜索
- 零信任与 RBAC 权限增强
- 蓝绿 / Canary 发布模式支持

---

# ✅ 总结

**iN 架构体系**以 Cloudflare 为中枢、Firebase 为认证配置、Vercel 为用户入口，构成三元分布式现代系统，完美体现当代 Serverless 系统的能力组合与最佳工程实践。
