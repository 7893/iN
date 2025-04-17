# iN 项目阶段报告（交接用）

> ⏱ 截至时间：2025年04月18日 03:08:34（韩国标准时间）

---

## 1. 项目目标与技术栈

- **项目目标**：构建基于 Cloudflare 的自动化图片处理与管理系统（涵盖下载、元数据提取、AI 分析、向量化、存储与检索）。
- **核心技术**：
  - Cloudflare Workers（后端）
  - Cloudflare Pages（前端 in-pages）
  - Cloudflare D1（数据库）
  - Cloudflare R2（对象存储）
  - Cloudflare Queues（任务队列）
  - Cloudflare Durable Objects（状态协调 TaskCoordinatorDO）
  - Cloudflare Vectorize（向量存储与搜索）
  - Terraform（基础设施即代码）
  - GitLab CI/CD（自动化流程）
  - pnpm + TypeScript（包管理与开发语言）
- **架构特点**：Monorepo 结构（apps/, packages/, infra/），模块化 Worker + 任务队列驱动异步流程。

---

## 2. 当前已完成并运行正常的部分

- **前端 CI/CD**：apps/in-pages 的 Lint → Test → Build (vite) → Deploy 已跑通  
  - 主分支推送后自动部署到：
    - https://head.in-pages.pages.dev  
    - https://in-pages.pages.dev  

- **Terraform 基础设施定义**：infra/ 目录下定义了 D1、Queues、Workers、Pages 项目资源。
- **密钥管理流程**：
  - `.env.secrets` → 同步脚本 → Cloudflare Secrets Store / GitLab CI/CD Variables
  - 包括 HMAC/JWT 密钥 和 CLOUDFLARE_API_TOKEN
- **Worker 配置 wrangler.toml**：已配置绑定（D1、Queues、DO、R2、Secrets 等）。
- **共享库 packages/shared**：logger.ts、trace.ts、auth.ts 已实现。
- **Durable Object Namespace**：TaskCoordinatorDO 已部署成功。

---

## 3. 亟需完成的核心工作（优先级排序）

### 🔺 高优先级

- **编写核心业务逻辑**：
  - 各 Worker 代码目前为空
  - 需实现 API 路由、队列消费者逻辑（含幂等）、DO 协调逻辑等

- **验证端到端日志推送**：
  - Axiom Logpush 已配置
  - 需实际部署产生日志的 Worker

- **确保测试稳定性与覆盖率**：
  - nanoid + vitest 配置需确认
  - 需要为共享库写测试

- **创建 Vectorize Index**：
  - in-vectorize-a-index-20250402 需手动创建

### 🟡 中优先级

- **添加 Worker CI/CD**：在 `.gitlab-ci.yml` 添加构建和部署逻辑
- **添加 IaC CI/CD**：
  - 建议迁移 Terraform State 至 GitLab
  - 添加 terraform plan/apply 作业（支持手动审批）
- **实现安全逻辑**：
  - 使用 `auth.ts` 做认证
  - 接口应有鉴权 + 输入验证
  - CI 中加入依赖扫描

---

## 4. 已知问题与关键决策点

- **Terraform 状态问题**：plan 曾阻塞，已解决但原因未明，建议使用 GitLab Managed State。
- **测试配置问题**：nanoid 报错需确认 vitest/vite 配置项 `ssr.noExternal`。
- **ESLint 配置**：
  - 使用 Flat Config (`eslint.config.mjs`)
  - 添加 CF 全局变量
  - 关闭了 `no-empty-interface` 和 `no-empty-object-type`
- **前端部署模式**：使用 Cloudflare Pages，worker.ts 已移除
- **Secrets 同步策略**：依赖 `.env.secrets` + `sync-*.sh` 脚本

---

## 5. 关键资源与文件位置

- **代码仓库**：`~/iN/`（GitLab）
- **核心代码路径**：
  - apps/*：各类应用
  - packages/*：共享库
- **基础设施代码**：infra/
- **CI/CD 配置**：`.gitlab-ci.yml`
- **Worker 配置**：`apps/*/wrangler.toml`
- **配置文件**：
  - TypeScript: `tsconfig.base.json`, `tsconfig.json`
  - ESLint: `eslint.config.mjs`
  - 测试: `vitest.config.ts`
- **Secrets 来源**：
  - 本地：`.env.secrets`
  - Cloudflare Secrets Store
  - GitLab CI/CD 变量
- **文档建议**：将 Markdown 文档集中整理到 `docs/` 目录中

---

## 🔚 接手须知

- 基础架构和前端流水线已就绪
- 后端业务逻辑几乎为空，CI/CD 自动化与日志链路尚未完备
- 推荐先做以下事项：
  1. 验证日志功能
  2. 确保测试可用
  3. 创建向量索引
  4. 启动业务逻辑开发，并逐步完善安全、测试和 CI/CD
