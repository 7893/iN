# 📘 iN 项目命名规范总览

本规范文档旨在统一 iN 项目的各类命名规则，确保代码、基础设施、CI/CD 等资源具备一致性、可读性和可维护性。

---

## 🧱 1. 基础设施资源命名规则（已确认）

| 类型             | 命名规则格式                             | 示例 |
|------------------|------------------------------------------|------|
| Worker           | `iN-worker-[顺序字母]-[功能]-[日期]`     | `iN-worker-A-api-gateway-20250402` |
| Queue            | `iN-queue-[顺序字母]-[功能]-[日期]`       | `iN-queue-A-imagedownload-20250402` |
| Durable Object   | `iN-do-[顺序字母]-[功能]-[日期]`          | `iN-do-A-task-coordinator-20250402` |
| R2               | `iN-r2-[顺序字母]-[功能]-[日期]`          | `iN-r2-A-bucket-20250402` |
| D1               | `iN-d1-[顺序字母]-[功能]-[日期]`          | `iN-d1-A-database-20250402` |
| Vectorize        | `iN-vectorize-[顺序字母]-[功能]-[日期]`   | `iN-vectorize-A-index-20250402` |
| Pages            | `in-pages`（固定名称）                    | `in-pages` |
| Logpush          | `iN-logpush-[顺序字母]-[目标平台]-[日期]`| `iN-logpush-A-axiom-20250402` |

说明：
- 顺序字母反映系统流程中的部署优先级。
- 所有日期建议使用部署决策日期，如 `20250402`。

---

## 🗂 2. 项目代码目录结构命名规范

### apps 目录

```bash
apps/
├── in-pages/
├── iN-worker-A-api-gateway-20250402/
├── iN-worker-B-user-api-20250402/
├── ...
```

说明：
- 与 Terraform 中的资源命名完全对齐，便于对应。
- 每个子目录都包含一个独立的 `package.json`。

### packages 目录

```bash
packages/
├── shared/
├── ai-worker-logic/
├── config-worker-logic/
├── download-worker-logic/
├── ui/
├── typescript-config/
├── eslint-config/
```

说明：
- 所有目录使用 `kebab-case` 命名。
- `*-logic` 表示该包只包含业务逻辑（不可部署）。

---

## 🧾 3. Terraform 文件命名规范

```bash
infra/
├── workers/iN-worker-A-api-gateway-20250402.tf
├── queues/iN-queue-A-imagedownload-20250402.tf
├── ...
```

说明：
- Terraform 文件名应与实际资源名保持一致。
- 子目录以资源类型组织（workers、queues、r2 等）。

---

## 🧬 4. 项目代码内部命名规范

### 变量 / 函数 / 文件 / 模块

| 类型       | 命名风格   | 示例                      |
|------------|------------|---------------------------|
| 变量名     | camelCase  | `taskId`, `userConfig`   |
| 常量       | UPPER_CASE | `MAX_TASK_TIMEOUT`       |
| 函数名     | camelCase  | `handleImageUpload`      |
| 文件名     | kebab-case | `task-utils.ts`          |
| 模块名     | kebab-case | `ai-handler.ts`          |
| 类型名     | PascalCase | `UserPayload`, `TraceId` |

说明：
- 避免缩写，保持语义明确。
- 纯函数应命名为动词短语，如 `extractMetadata()`。
- 所有日志调用必须包含 `traceId`。

---

## 🔁 5. Git 分支命名规范

| 类型         | 格式示例                               |
|--------------|----------------------------------------|
| Feature      | `feature/[模块]-[简短描述]`             |
| Fix          | `fix/[模块]-[bug简述]`                 |
| Release      | `release/[版本号]`                     |
| Hotfix       | `hotfix/[版本号]-[紧急修复内容]`       |

**示例：**
```bash
feature/ai-vector-search
fix/config-traceid-missing
release/v1.2.0
```

---

## 🧰 6. CI/CD Workflow 文件命名规范

```bash
.github/workflows/
├── lint.yml
├── test.yml
├── deploy-worker-A.yml
├── terraform-apply.yml
```

说明：
- 每个 Worker 可有独立部署 workflow。
- Terraform 操作需显式标识为 `plan` / `apply`。

---

## 📜 7. 日志与追踪字段命名规范

| 字段名       | 描述                               |
|--------------|------------------------------------|
| `traceId`     | 请求链路追踪标识（logger/trace.ts） |
| `taskId`      | 当前处理任务唯一 ID                |
| `level`       | 日志等级：info/warn/error         |
| `timestamp`   | 日志时间戳（ISO 格式）            |
| `worker`      | 当前日志产生的 Worker 名称        |

---

## 🔑 8. Cloudflare Secrets 命名规范

格式：
```bash
CF_SECRET_IN_[用途]_KEY
```

示例：
- `CF_SECRET_IN_HMAC_SECRET`
- `CF_SECRET_IN_VECTORIZE_TOKEN`

---

## 📝 9. Markdown 文档命名规范

| 类型               | 文件名                           |
|--------------------|----------------------------------|
| 架构总览文档       | `architecture-overview.md`       |
| 命名规范文档       | `iN-naming-conventions.md`       |
| 实施计划文档       | `implementation-plan.md`         |
| 路线图与未来规划   | `iN-future-modernization.md`     |
| 资源清单与职责     | `iN-resources-and-duties.md`     |
| Worker 文档        | `worker-[模块名].md`              |

---

如需未来变更命名规范，建议新增 `iN-naming-conventions-history.md` 文档记录演进过程。
