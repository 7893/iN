# iN 项目命名规则说明文档

**版本更新日期**：2025-04-13  
**更新依据**：根据实际项目目录结构（Ubuntu 上 `~/iN` 目录）进行全面梳理  
**本次更新内容**：
- 完善 Cloudflare 基础设施资源的命名规则（全小写 + 分类字母 + 描述 + 日期）
- 明确代码目录（apps, packages, infra）中命名风格
- 增加约定规范内容说明，便于后续开发协作

---

## 一、Cloudflare 基础设施资源命名规则

所有资源统一使用小写，统一以 `in-` 开头，结尾为部署日期（格式为 `YYYYMMDD`），中间为：

- `worker`: Worker 服务资源（如 `in-worker-a-api-gateway-20250402`）
- `queue`: 消息队列（如 `in-queue-a-image-download-20250402`）
- `d1`: 结构化数据库（如 `in-d1-a-database-20250402`）
- `r2`: 对象存储桶（如 `in-r2-a-bucket-20250402`）
- `vectorize`: 向量索引资源（如 `in-vectorize-a-index-20250402`）
- `do`: Durable Object 命名空间（如 `in-do-a-task-coordinator-20250402`）
- `pages`: Cloudflare Pages 资源（如 `in-pages`）
- `logpush`: 日志推送配置（如 `in-logpush-a-axiom-20250402`）

> 所有资源根据实施顺序从 `a` 开始编号。资源部署日期作为命名后缀的一部分。

---

## 二、项目代码目录命名规范

### apps/

- 命名形式：`iN-worker-<顺序字母>-<功能名>-<部署日期>`
- 示例：`iN-worker-a-api-gateway-20250402`
- 特殊：Cloudflare Pages 项目固定为 `in-pages`（简洁命名，无需编号）

### packages/

- 共享逻辑库：`<功能名>-worker-logic`（如 `download-worker-logic`）
- 基础包命名示例：
  - `shared`: 通用库
  - `ui`: UI 组件
  - `eslint-config`: ESLint 配置
  - `typescript-config`: TypeScript 配置
  - `types`: 类型声明包

### infra/

- 每类资源一个子目录，如 `workers/`, `queues/`, `d1/`, `r2/`, `vectorize/`
- 每个子目录中包含 `main.tf`, `providers.tf`, `variables.tf`
- 所有资源配置文件命名应与资源命名保持一致

---

## 三、通用命名规则

- 命名统一使用 `-` 连接各部分，不使用 `_` 或驼峰命名
- 文件与目录均遵循统一命名规则（唯一例外：代码内类/函数等可使用驼峰）
- 所有 Cloudflare 部署资源名使用小写（Cloudflare 要求）
- 所有资源名称必须具备可追踪性、语义清晰、部署时间信息

---

## 四、后续维护建议

- 所有新建资源或模块需遵守此命名规则
- 若命名规则需更新，应在本文件中注明变更原因与时间，确保团队一致理解
- 可为此文档建立 Git Hook 校验机制，确保规范性落地

