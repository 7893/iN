# 🧹 Git 历史敏感信息清理记录（git filter-repo + Gitleaks）(架构版本 2025年5月21日)

本文档记录本项目在开发过程中进行的一次或多次 Git 历史敏感信息清理操作。保持 Git 仓库的清洁对于项目安全至关重要。
最近一次检查/操作日期：YYYY年MM月DD日 (请在此处记录实际操作日期)

---

## ✅ 问题起因与识别

在 Git 历史记录中，可能会因疏忽提交以下类型的敏感信息：
- API 密钥（例如 Cloudflare API Token, GCP API Keys）
- 服务账号 JSON 凭证 (例如 GCP Service Account Keys)
- 数据库连接字符串或密码
- Terraform 状态文件 (`.tfstate`) 或变量文件 (`.tfvars`) 中包含的未加密密钥
- 其他 OAuth 凭证或私钥

这些敏感信息可以通过以下方式被识别：
- 手动代码审查。
- 使用自动化工具，如 **Gitleaks**，并将其集成到 **GitHub Actions** CI 流程中，在每次提交或 PR 时自动检测。
  ```bash
  # Gitleaks 检测命令示例 (在 GitHub Actions 中运行)
  gitleaks detect --source . --report-format sarif --report-path gitleaks-report.sarif -v