# 🌿 Git 分支策略规范  
📄 文档名称：branch-strategy-20250422.md  
🗓️ 更新时间：2025-04-22  

---

## 📁 主分支定义

| 分支名 | 用途 | 自动部署 |
|--------|------|------------|
| `main` | 主生产分支，受保护，仅合并变更 | ✅ Vercel Production |
| `dev`  | 主开发分支，日常开发合并 | ✅ Vercel Preview |
| `hotfix/*` | 紧急修复分支 | ✅ 手动合并触发部署 |
| `feature/*` | 新功能开发临时分支 | ❌ 不自动部署 |
| `docs/*` | 文档维护分支 | ❌ |

---

## 🧪 流程建议

- 所有功能应由 `feature/*` 派生并通过 MR 合并至 `dev`
- 阶段性版本开发完成后，从 `dev` 合并至 `main`
- `main` 分支必须通过 GitLab 审查并验证 CI/CD 成功
- 发布版本建议打 Tag：如 `v0.1.0`

---

## 🔁 与 Vercel 配合

- `dev` 分支自动绑定 Vercel Preview 环境
- `main` 分支绑定 Vercel 正式环境
- 环境变量通过 `VERCEL_ENV` 自动识别：`development` / `preview` / `production`
