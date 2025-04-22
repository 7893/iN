# 🧑‍💻 编码与风格规范  
📄 文档名称：coding-guidelines-20250422.md  
🗓️ 更新时间：2025-04-22  

---

## 🧱 通用规则

- 使用 TypeScript 编写所有业务逻辑
- 遵循函数式编程风格：纯函数、不可变、组合优先
- 所有模块需模块化拆分，副作用需封装进共享库

---

## 🌐 Cloudflare Worker 编码规范

- 每个 Worker 独立部署、独立 wrangler.toml、命名规范一致
- 所有 Worker 必须使用 `logger.ts`, `trace.ts`, `auth.ts`
- 所有 queue 消费逻辑必须幂等
- 所有状态操作走 `task.ts` 提供的接口，不允许绕过 DO

---

## 🎨 前端（Vercel + SvelteKit）

- 前端页面按 route 结构划分，统一使用 Layout 组件
- 所有 API 请求封装至 `lib/api.ts`，统一注入 Auth Token 与错误处理
- Tailwind 用于样式定义，禁止内联样式
- 禁止将密钥、地址硬编码进页面，全部使用 PUBLIC_ 环境变量导入

---

## 🔐 安全与验证

- 所有接口入参使用 Zod 校验器验证类型与范围
- 所有敏感数据使用 Secrets Store 管理，禁止出现在源码中
- 日志输出需结构化且禁用敏感字段打印
