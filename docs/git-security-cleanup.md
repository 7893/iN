# 🧹 Git 历史敏感信息清理记录（git filter-repo + Gitleaks）

本项目已完成一次完整的 Git 历史敏感信息清理操作，以下为操作过程记录和安全措施回顾。

---

## ✅ 问题起因

在 Git 历史记录中发现以下敏感信息泄露：

- `infra/terraform.tfvars` 中包含 `cloudflare_api_token`
- `infra/.terraform/terraform.tfstate` 中包含 `gitlab personal access token (PAT)`

通过 [Gitleaks](https://github.com/gitleaks/gitleaks) 自动集成于 CI 检测出：

```bash
gitleaks detect --report-format sarif --report-path gitleaks-report.sarif
```

---

## 🛠 清理操作步骤（Git 历史重写）

### 1. 克隆干净仓库副本用于操作

```bash
git clone git@gitlab.com:79/in.git in-clean
cd in-clean
```

### 2. 使用 git-filter-repo 移除历史中的敏感文件

```bash
git filter-repo --path infra/terraform.tfvars --invert-paths
git filter-repo --path infra/.terraform/terraform.tfstate --invert-paths
```

> 注意：每次运行 `git filter-repo` 会清除历史中该文件的所有版本，并移除 remote。

### 3. 恢复远程 origin 并强制推送覆盖旧历史

```bash
git remote add origin git@gitlab.com:79/in.git
git push origin --force --all
```

> ⚠️ 强推后，其他协作者需要重新克隆仓库

---

## ✅ 成功验证标准

- Gitleaks 在 CI 中报告 `leaks found: 0`
- `.git` 中找不到任何 tfvars、.tfstate、Token 内容
- `.gitignore` 配置已屏蔽该类文件防止再次提交

---

## 🧩 后续建议

- 启用 Terraform Remote Backend，避免 tfstate 本地文件化
- 所有 Secrets 使用 `.env.secrets` 管理 + 不提交
- GitLab CI/CD 中改为使用变量形式，如 `TF_VAR_cloudflare_api_token`
