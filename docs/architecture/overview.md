# 写入架构概要到 markdown 文件
from pathlib import Path

md_content = """
# iN 项目架构概要

> 时间：2025年4月10日  
> 地点：韩国 首尔（KST）

---

## 1. 项目目标与原则

- **目标：** 构建一个基于 Cloudflare 的、分布式的图片自动化处理系统，涵盖获取、处理、存储、搜索与分类功能。
- **核心原则：**
  - 异步、事件驱动、模块化、可扩展
  - 安全性、高可观测性、性能与成本优化
  - 深度使用 Cloudflare Native 服务
  - 基础设施即代码（IaC）全面落地

---

## 2. 核心技术栈

- **计算：** Cloudflare Workers（优先 Standard，必要时使用 Unbound）
- **消息队列：** Cloudflare Queues + DLQ
- **状态协调：** Durable Objects（按 taskId 分片）
- **存储：** R2（对象），D1（结构化），Vectorize（向量）
- **前端部署：** Cloudflare Pages
- **日志：** Logpush → Axiom / Logtail / Sentry 等
- **AI 能力：** Cloudflare AI（为主）或外部 AI（补充）

---

## 3. 开发与管理方式

- **代码管理：** Monorepo（pnpm / Turborepo）
- **基础设施管理：** Terraform 管理所有资源
- **密钥管理：** Cloudflare Secrets Store

---

## 4. 架构风格与通信模型

- **分层结构：** 网关层 / API 层 / 数据处理层 / 协调层 / 存储层
- **模块化原则：** Worker 职责单一、逻辑轻量
- **通信模型（混合式 Pub/Sub）：**
  - **核心流程：** 用任务队列驱动（Download → Metadata → AI）
  - **广播扩展：** 用事件队列广播关键事件（如 image.downloaded）

---

## 5. 关键组件说明

- **API Gateway Worker：** 路由、JWT/HMAC 验证、traceId 注入
- **API Workers：** 单一职责，处理查询 / 配置 / 用户接口
- **Data Workers：** Download、Metadata、AI 等响应队列执行任务
- **Config Worker：** 生成任务，投递到任务队列，配置调度
- **Task Coordinator DO：** 按 taskId 管理任务状态流转
- **Queues：** TaskQueue + EventQueue（含 DLQ）
- **Plugins：** 插件系统（源/存储/AI）预留

---

## 6. 图片处理策略

- 核心流程不做图片变换（避免性能瓶颈）
- 外包方案：
  - 优先：外部 Edge Function（如 Supabase）
  - 可选：专用 Worker（使用 Workers Unbound）

---

## 7. 可观测性

- **追踪：** traceId 贯穿请求 + 队列 + 日志
- **日志：** 结构化 JSON 日志（包含 traceId, taskId, eventType 等）
- **日志收集：** Cloudflare Logpush + 第三方平台
- **分析能力：** traceId 实现全链路追踪、错误分析、性能瓶颈排查

---

## 8. 安全性设计

- **用户认证：** JWT
- **组件间认证：** HMAC 签名机制
- **Secrets 管理：** Cloudflare Secrets Store
- **资源保护：** 暂不使用 Zero Trust，依赖 IP 限制 / 登录保护 / VPN

---

## 9. 测试策略

- 单测：Vitest / Jest
- 集成测试：MockQueue + 多模块链路
- E2E 测试：Playwright / Cypress

---

## 10. 成本控制策略

- 避免不必要的 Unbound Worker 使用
- 任务处理时间尽量短（降低 DO 活跃时长）
- 接受付费，追求高性价比运行
- 重点关注 Durable Object + R2 存储成本

---

## 11. 演进策略

- 从最小可用系统 (MVP) 出发
- 持续添加插件支持、日志系统、调试工具
- 支持灰度发布、管理后台、权限控制、计费系统等中长期能力演进

---

> 📘 本文作为 `/docs/architecture/overview.md` 使用，建议作为 iN 文档系统的首章阅读入口。
"""

path = Path("/mnt/data/overview.md")
path.write_text(md_content.strip(), encoding="utf-8")
path
