# ✅ security-checklist-20250521.md (架构版本 2025年5月21日)

本文档为 iN 项目在 Vercel, Cloudflare, Google Cloud Platform (GCP) 和 GitHub 上的核心安全措施清单，旨在确保项目在设计、开发和部署过程中的安全性。清单项应定期审查和更新。

---

## 🔑 身份与访问管理 (IAM)

- **[ ] 用户认证**:
    - [ ] **GCP Identity Platform (GCIP)** 已配置并启用，用于用户注册和登录。
    - [ ] 支持至少一种 OAuth 提供商 (如 Google, GitHub)。
    - [ ] （可选）为 GCIP 用户启用多因素认证 (MFA)。
- **[ ] 服务账号 (GCP & Cloudflare)**:
    - [ ] 所有 GCP 服务（Cloud Functions/Run, Pub/Sub 等）使用具有最小权限的专用服务账号运行。
    - [ ] Cloudflare Workers 访问 GCP 服务时，使用专用的 GCP 服务账号凭证。
    - [ ] 避免使用默认服务账号或用户凭证进行服务间调用。
- **[ ] IAM 权限 (GCP & Cloudflare)**:
    - [ ] 所有用户和服务账号均遵循最小权限原则。
    - [ ] 定期审查 IAM 策略和角色绑定。
- **[ ] API 认证**:
    - [ ] Cloudflare API Gateway Worker 强制验证所有入站请求的 GCIP ID Token。
    - [ ] （如果适用）内部服务间调用（如 Worker 到 Worker，或 GCP 服务到 GCP 服务）使用安全的认证机制（如 IAM Token, HMAC 签名）。

## 🔒 密钥与配置管理

- **[ ] 敏感信息存储**:
    - [ ] **严禁**在代码仓库中硬编码任何密钥、密码、API Token 或服务账号JSON文件。
    - [ ] **GitHub Actions Secrets**: 用于存储 CI/CD 流程中需要的部署凭证。
    - [ ] **Vercel Environment Variables**: 存储前端应用所需的环境变量 (区分 Production, Preview, Development)。
    - [ ] **Cloudflare Secrets**: 存储 Cloudflare Workers 运行时需要的密钥。
    - [ ] **GCP Secret Manager**: （推荐）用于存储 GCP 服务运行时需要的敏感配置和密钥。
- **[ ] `.gitignore`**:
    - [ ] `.gitignore` 文件已正确配置，包含所有本地密钥文件 (`.env*`, `*.pem`, `service-account-*.json` 等)、Terraform 状态文件等。
- **[ ] Git 历史扫描**:
    - [ ] 已完成对 Git 历史的敏感信息扫描 (例如使用 Gitleaks)。
    - [ ] Gitleaks 或类似工具已集成到 GitHub Actions CI 流程中，防止新的敏感信息提交。

## 🛡️ 应用与服务安全

- **[ ] 输入验证**:
    - [ ] 所有外部输入（API Gateway Worker 接收的请求, GCP Function/Run 从 Pub/Sub 接收的消息）均使用 Zod 或类似库进行严格的模式和类型验证。
- **[ ] 输出编码 (前端)**:
    - [ ] Vercel 前端在展示用户提供或后端返回的数据时，进行适当的 HTML 编码以防止 XSS。
- **[ ] CORS 配置 (Cloudflare API Gateway)**:
    - [ ] 已配置严格的 CORS 策略，仅允许来自 Vercel 等受信任域名的请求。
- **[ ] Cloudflare 安全特性**:
    - [ ] （推荐）启用 Cloudflare WAF (Web Application Firewall) 规则集。
    - [ ] （推荐）配置适当的速率限制规则。
    - [ ] 确保 DNSSEC 已启用。
- **[ ] GCP 服务安全配置**:
    - [ ] **Pub/Sub**: 主题和订阅的 IAM 权限已正确配置。
    - [ ] **Cloud Functions/Run**: 配置最小权限的服务账号；如果为 HTTP 触发，配置调用权限。
    - [ ] **Firestore/Datastore**: 安全规则已配置并测试，基于用户身份控制数据访问。
    - [ ] **Cloud Storage (GCS)**: 存储桶和对象权限设置为私有（除非明确需要公开），启用服务器端加密。
- **[ ] 幂等性**:
    - [ ] 所有由 GCP Pub/Sub 触发的 GCP Cloud Functions/Run 服务均已实现幂等性处理。
- **[ ] Durable Object 安全**:
    * [ ] `TaskCoordinatorDO` 的状态更新接口设计为不可被未授权的外部直接调用，只能由受信任的内部 Worker 或 GCP 服务回调（需设计安全的回调机制）。

## 📦 依赖与基础设施安全

- **[ ] 依赖项管理**:
    - [ ] （推荐）使用 GitHub Dependabot 或类似工具定期扫描并更新存在已知漏洞的第三方依赖包 (npm, Go 等)。
- **[ ] 基础设施即代码 (Terraform)**:
    - [ ] Terraform 代码接受审查，确保资源配置符合安全最佳实践。
    - [ ] Terraform 状态后端 (如 GCS Bucket) 已配置严格的访问控制和加密。
    - [ ] 不在 Terraform 代码中硬编码敏感信息。

## 📊 日志与监控

- **[ ] 日志内容安全**:
    - [ ] 所有服务的日志输出（Vercel, Cloudflare, GCP）均已进行脱敏处理，不记录原始密钥、密码、PII 等敏感信息。
    - [ ] 日志中包含 `traceId` 和 `taskId` (如果适用) 以支持链路追踪和审计。
- **[ ] 日志传输与存储**:
    - [ ] 日志从 Cloudflare 和 Vercel 安全地传输到 GCP Cloud Logging。
    - [ ] GCP Cloud Logging 的存储和访问权限已适当配置。
- **[ ] 安全告警**:
    - [ ] 在 GCP Monitoring 中配置针对可疑活动、重要安全事件（如认证失败次数过多、IAM权限变更、DLT消息堆积）的告警。

## 🔁 定期审查与流程

- **[ ] 定期安全审计**: 计划定期对整体架构、IAM配置、安全规则等进行安全审查。
- **[ ] 紧急事件响应计划**: （可选，对于更成熟项目）有基本的安全事件响应流程。

---
文档名：security-checklist-20250521.md (原 security-checklist-20250422.md)  
更新日期：2025-05-21