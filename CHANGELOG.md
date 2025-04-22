# 📜 CHANGELOG

> 所有重要变更、迭代内容与架构决策将记录于此。  
> 遵循 [Keep a Changelog](https://keepachangelog.com/) 规范，结合实际项目演进。

---

## [Unreleased] – 2025-04-22 更新

### ✨ 新增
- 设计并记录“混合事件驱动架构”主链与副作用逻辑分离方案。
- 补充一批现代工程文档：`architecture-summary-*`, `project-overview-*`, `phased-implementation-*`, `frontend-pages-map-*`, `event-schema-spec-*`, `shared-libs-overview-*`, `ci-structure-*` 等。
- 确立 MVP 收敛目标：向量搜索、状态展示、DLQ 自动重试、事件日志增强 Worker。
- 启用新架构版本下完整的资源命名清单与 Terraform 注册方式。

### 🛠 改进
- 重写 `README.md`，明确项目目标为现代 Serverless 架构实验平台，由生成式人工智能协助完成。
- 删除插件系统、蓝绿部署与多租户架构相关描述，聚焦单人实验性目标。
- 调整 Worker 职责与模块划分，简化后端执行链条逻辑。
- 更新所有文档以符合命名规范、更新时间戳和模块一致性。
- 明确前端页面为最多三页（任务发起、任务状态、图片搜索），并保留 SSR 兼容性设计。

### 🐛 修复
- 修复旧有 `.env.secrets` 同步脚本对空值变量处理不一致的问题。
- 修复 `apps/in-pages` 中 CI/CD 构建脚本路径错误，现已匹配新版目录结构。

### 🗑️ 删除
- 移除旧版 Roadmap 草案中关于插件生命周期系统与多租户结构的描述。
- 删除不再使用的文档文件：`infra-resources.md`, `infra-resources-detailed.md`, `project-handbook.md` 等。

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

## ✅ 当前收敛路线图（Roadmap）

- [x] 架构定型与资源注册命名完成
- [x] 前端页面结构设计（最多 3 页）
- [x] 项目目标文档与技术说明完善
- [ ] 实现核心任务链 Download → Metadata → AI
- [ ] 完成状态协调 DO 与前端任务展示对接
- [ ] 接入 Vectorize 向量索引接口与搜索逻辑
- [ ] 实现 DLQ 自动重试机制
- [ ] 构建事件驱动日志增强订阅者 Worker
- [ ] 打通 Logpush → Axiom 的仪表盘指标流
