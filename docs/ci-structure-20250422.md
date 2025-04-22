# 🛠️ CI/CD 流水线结构说明  
📄 文档名称：ci-structure-20250422.md  
🗓️ 更新时间：2025-04-22  

---

## 🎯 CI/CD 目标

通过 GitLab CI 自动实现代码质量检查、构建、资源管理与部署，保证发布流程可控、可观测、可恢复。

---

## ✅ 核心阶段流程

```yaml
stages:
  - lint
  - test
  - build
  - plan
  - deploy
```

---

## 📦 每阶段任务说明

| 阶段 | 工具 | 描述 |
|------|------|------|
| lint | eslint | 校验代码规范 |
| test | vitest | 运行所有单元测试 |
| build | turborepo | 构建前端与 Worker |
| plan | terraform | IaC 检查基础设施变更 |
| deploy | wrangler, vercel | 部署到 Cloudflare / Vercel |

---

## 🔑 配置管理

- 使用 `.env.secrets` 管理 Secrets
- 使用 `tools/sync-to-gitlab.sh` 同步到 GitLab
- 所有 ENV 隐私变量不可硬编码

---

## 🚥 分支触发策略

| 分支 | 自动部署 | 说明 |
|------|----------|------|
| `main` | ✅ | Production |
| `dev` | ✅ | Preview |
| `feature/*` | ❌ | 手动合并 |
