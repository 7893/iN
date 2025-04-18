# 📜 CHANGELOG

> 所有重要变更、迭代内容与架构决策将记录于此。  
> 遵循 [Keep a Changelog](https://keepachangelog.com/) 规范，结合实际项目演进。

---

## [Unreleased]

### ✨ 新增
- 完成 `packages/shared` 中核心共享库 `logger.ts`, `trace.ts`, `auth.ts` 的实现。
- 成功配置并验证 `apps/in-pages` 前端应用的完整 CI/CD 流程 (Lint → Test → Build → Deploy)。
- 采用 ESLint Flat Config (`eslint.config.mjs`) 并配置 Cloudflare 全局变量。

### 🛠 改进
- 最终确认前端部署方案为 Cloudflare Pages 产品。
- 解决了先前遇到的 Terraform plan 状态读取/认证阻塞问题 (具体原因待查)。
- 完善 Secrets 同步脚本 (`sync-*.sh`)，确保与 GitLab CI/CD 及 Cloudflare Secrets Store 同步流程。

### 🐛 修复
- 识别并配置 Vitest (`vitest.config.ts` 中 `ssr.noExternal`) 以解决 `nanoid` 在测试中报错的问题。

### 🗑️ 删除
- 从 `apps/in-pages` 项目中移除了不再需要的 `worker.ts` 文件。

---

## [2025-04-18] - 项目结构与架构定型 ✅

### 📌 关键里程碑
- 架构定稿：异步队列 + DO 状态协调 + 结构化日志链路。
- Worker 组件完整命名落地（11 个 Workers + 6 个 Queues + 1 DO）。
- 前端 Pages 部署路径规范化。
- 所有基础配置（ESLint、tsconfig、CI、Secrets）初始化完成。
- 日志链路通过 Axiom Logpush 完成验证。

---

## [2025-04-10] - Durable Object 初步实现

- 成功部署 `in-do-a-task-coordinator` Namespace。
- 实现 Task 状态更新封装库 `task.ts`。
- 为所有任务消费 Worker 明确幂等性要求。

---

## [2025-04-04] - 项目初始化

- 创建 Monorepo 项目结构，集成 pnpm + Turborepo。
- 初始化 Cloudflare Workers 架构骨架。
- Terraform 成功管理 D1、Queues、Workers、Pages 外壳。
- 引入基础 CI/CD 流程、项目规范配置（ESLint、tsconfig、vitest）。

---

## 🧭 Roadmap 草案

- [ ] 实现核心任务管线完整业务逻辑（Download → Metadata → AI）。
- [ ] 接入 Canary 流程与 Rollback 策略。
- [ ] 插件生命周期系统（onTaskCreate, onMetadataExtracted）。
- [ ] 多租户结构与权限系统设计。
- [ ] Zero Trust 安全机制（Cloudflare Access）。
- [ ] SLA / SLO 指标与告警体系。
- [ ] 引入 Chaos Worker 模拟异常恢复机制。
