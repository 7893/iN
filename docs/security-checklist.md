# ✅ 项目安全检查清单（Security Checklist）

适用于项目开发、部署、开源前的安全自查与审计。

---

## ✅ 基础安全

- [x] 所有密钥统一存储在 `.env.secrets` 中，未提交到仓库
- [x] `.gitignore` 中已屏蔽 `.env*`, `*.tfvars`, `*.tfstate*`, `.terraform/`
- [x] Git 历史中敏感内容已清除（使用 `git filter-repo`）
- [x] 所有 Token/Secrets 已迁移至 GitLab CI/CD 变量 或 Cloudflare Secrets Store
- [x] 本地配置文件中不含 hard-coded 密钥

---

## ✅ Git 安全

- [x] Gitleaks 已集成入 CI，扫描所有提交
- [x] 主分支设置为 Protected，禁止直接 Push
- [x] 项目已有明确分支管理策略（如 feature / dev / main）
- [x] 所有历史敏感文件（如 `terraform.tfvars`, `.tfstate`）已清理
- [x] `.gitignore` 避免再次提交

---

## ✅ CI/CD 安全

- [x] 所有环境变量由 GitLab CI 注入，未硬编码
- [x] Deploy 阶段限定仅 main 分支
- [x] Job 之间使用 `needs:` 串联控制部署时机
- [x] CI 日志中不输出敏感信息（通过 `--redact` 等方式屏蔽）

---

## ✅ Cloudflare 配置安全

- [x] 使用最小权限 API Token
- [x] 部署命令中通过 `wrangler` 调用 Secrets
- [x] 所有 Worker 绑定 Secrets 不暴露在源码中
- [x] 出口代理配置隐藏真实 IP (`HTTPS_PROXY`)

---

## ✅ 日志与可观测性安全

- [x] 所有日志为结构化输出，traceId 可追踪
- [x] 日志中脱敏敏感字段（如 headers, tokens）
- [x] Axiom Logpush 已配置并绑定 traceId 机制

---

## ✅ 项目文档与制度

- [x] 已创建 `git-security-cleanup.md` 记录历史清理过程
- [x] 已创建 `secure-practices.md` 记录最佳实践
- [x] 本 Checklist 文档已同步纳入仓库 `docs/`

---

## 🧠 建议：每次重大版本发布前复查此清单，确保安全无死角。
