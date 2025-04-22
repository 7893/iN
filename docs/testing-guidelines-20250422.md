# 🧪 测试规范与策略  
📄 文档名称：testing-guidelines-20250422.md  
🗓️ 更新时间：2025-04-22  

---

## 🎯 测试目标

确保所有模块具备足够的正确性、稳定性与可回归能力，支持 CI 中自动验证。

---

## 📐 测试金字塔策略

| 层级 | 工具 | 覆盖内容 | 要求 |
|------|------|----------|------|
| 单元测试 | Vitest | 纯函数、共享逻辑 | ✅ 必需，覆盖率 > 80% |
| 集成测试 | wrangler dev + curl/postman | Worker 与 API 交互 | ✅ 核心流程 |
| E2E 测试（可选） | Playwright | 前后端联动 + 用户行为 | 🔄 后期补充 |

---

## ✅ 当前测试组件建议

- `packages/shared-libs/logger.ts` / `trace.ts` / `auth.ts` 必须有 Vitest 测试
- 所有 Queue 消费逻辑需测试幂等性与异常处理
- 所有 API Worker 需测试认证失败、输入不合法、边界值

---

## 🧪 本地测试方式

```bash
# 单元测试
pnpm test

# 集成调试
wrangler dev
curl http://localhost:8787/api
```
