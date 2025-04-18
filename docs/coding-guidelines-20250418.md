
# iN 项目编码指南（超详细版）
> 版本 1.0 更新时间：2025-04-18 18:20:39 JST

本文档融合了：
- 先前**规划文档、目录规范、函数式原则、CI/CD 流程**  
- 你提供的编码要点（单一职责、DRY、幂等、日志追踪…）  
- 以及当前仓库结构与 Cloudflare Workers 生态的最佳实践  

旨在为 **iN** 项目提供端到端、高粒度的编码与协作规范。

---

## 目录
1. 项目目录与层次
2. 通用工程原则
3. TypeScript 语言与格式化
4. 函数式编程落地
5. 命名规范
6. 文件与模块组织
7. 接口 / DTO / 事件契约
8. 异步、错误与重试
9. 日志与追踪
10. 测试金字塔
11. 性能与资源优化
12. 安全最佳实践
13. CI/CD 校验与 Gate
14. 文档、注释与版本
15. Pull Request 流程
16. 参考链接

---

## 1 项目目录与层次

```text
/
├─ apps/                  # 可部署单元 (Workers / Pages / DO)
│   ├─ in-pages/          # 前端 Cloudflare Pages
│   ├─ iN-worker-a-*/     # API / Queue Workers
│   └─ iN-do-a-*/         # Durable Objects
├─ packages/
│   ├─ shared-libs/       # 横切工具: logger / trace / auth / task / events
│   ├─ *-worker-logic/    # 纯业务逻辑（无 I/O）
│   └─ types/             # 跨包公共类型
├─ infra/                 # Terraform
├─ docs/                  # 文档
├─ tools/                 # 脚本 (sync‑secrets, git‑cleanup…)
└─ .gitlab-ci.yml         # CI/CD 流水线
```

- **应用层**(`apps/`) 只处理边界：HTTP、Queue、DO 绑定。  
- **逻辑层**(`packages/*-worker-logic`) 纯函数或最小副作用。  
- **交叉层**(`shared-libs/`) 解决横切关注点。  
- **基础设施层**(`infra/`) 100 % IaC。  

---

## 2 通用工程原则

| 准则 | 说明 |
|------|------|
| **清晰 > Clever** | 代码应一眼能懂，避免晦涩技巧。 |
| **单一职责** | 模块/函数只做一件事 |
| **DRY** | 共用逻辑抽到 `packages/*-worker-logic` 或 `shared‑libs`。 |
| **幂等 & 可追踪** | 所有 Queue 消费者可安全重放；贯穿 `traceId` |
| **纯函数优先** | 副作用隔离在边缘 |
| **演进友好** | 预留扩展点，避免僵化 |

---

## 3 TypeScript 语言与格式化

- `strict: true`、`noUncheckedIndexedAccess: true`  
- ESLint Flat + `@typescript-eslint/*`；Prettier 行宽 100·单引号  
- 禁止 `any`；必要时 `unknown` + 类型守卫  
- `import type` 分离类型依赖，减小 bundle  

---

## 4 函数式编程落地

| 技巧 | 例子 |
|------|------|
| 纯函数 | `const resize = (img, w, h) => …` |
| 不可变对象 | `return { ...old, status: 'done' }` |
| 函数组合 | `pipe(download, extract, analyse)` |
| 副作用隔离 | I/O 写在 `effect/*.ts` |
| 幂等性 | Consumer 先检查 Task State 再执行 |

---

## 5 命名规范

| 对象 | 规则 | 示例 |
|------|------|------|
| 资源 | `in-worker-a-api-gateway-YYYYMMDD` | |
| 变量 | camelCase | `imageData` |
| 常量 | UPPER_SNAKE | `MAX_RETRY` |
| 类型/interface | PascalCase | `ImageMeta` |
| 文件 | kebab-case.ts | `user-service.ts` |

---

## 6 文件与模块组织

- **≤ 400 行/文件**  
- `index.ts` 仅聚合导出  
- 跨层依赖只流向 “下层” (无循环)  
- 公共 DTO → `packages/types/`  

---

## 7 接口 / DTO / 事件契约

### 7.1 REST API
* 路径复数名词 `/images`
* Zod 校验 Body & Query
* 标准错误格式  
```json
{ "error": { "code": "NOT_FOUND", "message": "...", "traceId": "…" } }
```

### 7.2 事件 (`INEvent<T>`)
```ts
interface INEvent<T> {
  id: string
  type: 'image.downloaded'
  data: T
  ts: string         // ISO
  traceId: string
}
```

---

## 8 异步、错误与重试

| 场景 | 动作 |
|------|------|
| 业务异常 | `throw new UserError('INVALID_INPUT')`, 返回 400 |
| 系统异常 | 记录 ERROR，返回 500 |
| 重试 | 指数退避 *3；失败进 DLQ |
| Queue ack | 仅在处理成功后确认 |

---

## 9 日志、追踪与可观测性

* 统一 `logger.ts`：`{ ts, level, msg, traceId, taskId, worker }`  
* 严禁输出 Secrets、PII  
* 使用 Axiom 仪表盘：Queue 深度、Worker 错误、DLQ 消息  

---

## 10 测试金字塔

| 层级 | 工具 | 目标 |
|------|------|------|
| 单元 | Vitest | 纯函数 & utils |
| 集成 | Miniflare + Vitest | Worker ↔ Logic ↔ Mock DO/R2 |
| E2E | Playwright | 用户核心流 |
| 覆盖率 | `> 80 %` packages/* | CI Gate |

---

## 11 性能与资源优化

* Worker 内存 < 128 MiB，CPU 密集外卸至 AI Service  
* DO 操作 < 30 ms；State 写入批量化  
* R2 采用分层哈希路径；向量批写 50 条/次  

---

## 12 安全最佳实践

| 项 | 约束 |
|----|------|
| Secrets | 仅 Cloudflare Secrets Store & CI 变量 |
| 输入验证 | Zod + 类型守卫 |
| Least Privilege | API Token 权限最小化 |
| 依赖扫描 | `pnpm audit`, `gitleaks_scan` |
| 日志脱敏 | 不记录 Token, JWT, PII |

---

## 13 CI/CD Gate

流水线阶段：

1. **lint** → ESLint + Prettier Check  
2. **test** → Unit + Integration + Gitleaks  
3. **build** → `pnpm build --filter=in-pages`  
4. **deploy** → Wrangler Pages (main)  

所有 Job 全绿方可合并 PR。

---

## 14 文档、注释与版本

* JSDoc 描述公开 API、复杂算法  
* 更新影响用户的变更 → `CHANGELOG.md`  
* 架构决策记录 ADR → `docs/adr/ADR-xxxx.md`  
* 每次 Release 用 GitLab Tag (`vx.y.z`) + Release Notes  

---

## 15 Pull Request 流程

1. `feature/<topic>` 分支  
2. 本地 `pnpm lint && pnpm test` ✅  
3. PR 描述 *What / Why / How*  
4. 至少 1 Review Approve  
5. CI 通过后 **Squash & Merge**  
6. 标注 Tag → 生产部署  

---

## 16 参考链接

* Cloudflare Workers Best Practices  
* TypeScript Handbook  
* 12 Factor App  
* Practical FP in TypeScript  
* GitLab CI/CD Docs

---

遵循以上准则，可确保 iN 代码库在 **可读、可测、可扩展、安全** 多维度保持行业领先水平。若需修订，请提交 PR 更新本文件并通知全体成员。
