# 🔐 项目安全最佳实践（iN Project）

本项目为现代 Serverless 架构，在安全设计方面遵循以下策略与约定，保障源码、运行时、配置与密钥的完整性与机密性。

---

## ✅ Secrets 管理

- 所有密钥集中管理在 `.env.secrets` 文件中
- 禁止将 Secrets 直接写入 `.tfvars`、`.ts`、`.yml`、`.json` 等源码文件中
- 使用脚本自动同步到：
  - ✅ Cloudflare Secrets Store
  - ✅ GitLab CI/CD Variables
- 对 Terraform 使用 `TF_VAR_` 变量机制注入敏感值

---

## ✅ Git 安全策略

- 已集成 Gitleaks 至 GitLab CI，扫描所有提交中的敏感信息
- 使用 `git filter-repo` 清除历史中误提交的 API Token / 密钥
- 添加 `.gitignore` 屏蔽常见高风险文件类型：
  - `infra/*.tfstate*`
  - `infra/terraform.tfvars`
  - `.env*`
  - `.DS_Store`

---

## ✅ Cloudflare 安全配置

- 使用最小权限 API Token（仅授予必要 R2/Queue/Worker 权限）
- 所有部署命令均通过 `wrangler` 工具带 secrets 执行
- 使用 HTTPS_PROXY 出口访问，提升隐蔽性与反扫描能力

---

## ✅ CI/CD 安全防护

- 所有构建与部署阶段均在 GitLab CI 中完成，使用受控环境
- 不允许直接部署未审核分支到生产环境
- 强制使用生产环境变量、主分支保护、Merge Request 审核流程

---

## ✅ 可观测性与日志追踪安全

- 所有日志采用结构化输出，使用 `traceId` 串联链路
- 敏感内容（如 Authorization header、secret 值）日志中被脱敏或略过
- Axiom 日志链路采用 `logpush` 推送方式，防止外部泄漏

---

## 🔚 总结

本项目已完成从代码、CI、Git 历史、Cloudflare 权限、密钥管理等全链路的安全体系构建，持续迭代中。建议开发者遵循以上约定，共同维护系统安全。
