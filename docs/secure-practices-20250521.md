# 🔐 安全实践指南与核对清单 (架构版本 2025年5月21日)
📄 文档名称：secure-practices-20250521.md
🗓️ 更新时间：2025-05-21
---
本指南为 iN 项目在 Vercel, Cloudflare, Google Cloud Platform (GCP) 和 GitHub 上的开发、部署和运维提供核心安全实践建议与核对清单。

## 🛡️ 一、通用安全原则

- **最小权限原则**: 所有用户账户、服务账号、API密钥都应只授予完成其任务所必需的最小权限。
- **纵深防御**: 在多个层面实施安全措施（网络、应用、数据、身份）。
- **安全左移**:尽早将安全考虑和实践融入开发生命周期 (DevSecOps)。
- **默认安全**: 系统设计应默认采用安全配置。
- **定期审计与更新**: 定期审查安全配置、依赖项和访问权限，并及时更新补丁。

---

## GITHUB"> 二、 GitHub 安全实践 (代码与CI/CD)

- **代码仓库安全**:
    * 使用 GitHub 的分支保护规则保护 `main` 和 `dev` 分支，要求 PR 审查和 CI 通过。
    * 定期审查仓库的协作者权限。
- **CI/CD 安全 (GitHub Actions)**:
    * **Secrets 管理**: 所有敏感凭证 (API Tokens, Service Account Keys) 必须存储在 GitHub Actions Secrets 中，绝不硬编码到 workflow 文件中。
    * **第三方 Actions 审查**: 谨慎使用第三方 GitHub Actions，审查其权限和安全性。
    * **依赖扫描**: 集成 Dependabot 或类似工具，自动扫描并提醒依赖库的安全漏洞。
    * **代码扫描**: 在 CI 流程中集成 Gitleaks 或类似的静态应用安全测试 (SAST) 工具，检测代码中的硬编码密钥或常见漏洞。
- **`.gitignore`**: 确保 `.gitignore` 文件有效屏蔽所有本地配置文件、密钥文件、`.env` 文件、Terraform 状态文件等。

---

## 🎨 三、Vercel 安全实践 (前端)

- **环境变量管理**:
    * 所有需要传递给前端应用的配置（如 API Gateway URL, GCIP 配置参数）通过 Vercel Environment Variables (Production, Preview, Development) 安全注入。
    * 严格区分构建时可访问和运行时可访问的环境变量。客户端可访问的变量必须以特定前缀 (如 `NEXT_PUBLIC_` 或 `VITE_`) 命名。
- **HTTPS 强制**: Vercel 默认提供并强制 HTTPS。
- **内容安全策略 (CSP)**: （推荐）配置 CSP HTTP 头部，限制浏览器加载资源的来源，减少 XSS 风险。
- **依赖项管理**: 与后端类似，定期更新前端依赖，防范客户端漏洞。
- **输出编码**: 对所有动态渲染到 HTML 中的内容进行适当编码，防止 XSS。

---

## ☁️ 四、Cloudflare 安全实践 (边缘与API网关)

- **API Gateway Worker 安全**:
    * **输入验证**: 对所有入站 API 请求的参数和请求体使用 Zod 等库进行严格校验。
    * **认证**: 验证来自前端的 GCP Identity Platform ID Token，确保请求的合法用户身份。
    * **授权**: （如果需要）基于用户身份和角色进行进一步的访问控制。
    * **速率限制**: 配置速率限制规则，防止滥用和暴力破解。
    * **CORS**: 正确配置 CORS 策略，仅允许来自 Vercel 等受信任域名的跨域请求。
- **Durable Objects (DO) 安全**:
    * DO 的方法调用应设计为只能由受信任的内部 Worker (如 API Gateway Worker 或特定的后端 Worker) 调用。
    * 谨慎处理从外部传入 DO 的数据。
- **R2, D1, Vectorize 安全**:
    * 配置严格的访问策略。如果数据不需要公开访问，则不开启公开访问。
    * Worker 访问这些存储服务时，使用绑定的服务或环境变量中安全的凭证。
- **WAF 与 DDoS 防护**: 利用 Cloudflare 提供的 Web Application Firewall (WAF) 规则集和 DDoS 防护能力。
- **Secrets 管理**: Worker 运行时需要的密钥（如访问GCP的凭证部分）通过 Cloudflare Secrets (环境变量) 安全注入。
- **日志与监控**:
    * Worker 日志应进行脱敏处理，避免记录原始敏感信息。
    * 通过 Logpush 将日志安全导出到 GCP Cloud Logging 进行集中分析和审计。

---

## 🚀 五、Google Cloud Platform (GCP) 安全实践 (核心后端)

- **Identity and Access Management (IAM)**:
    * **最小权限原则**: 为用户和服务账号 (Service Accounts) 授予完成其任务所需的最小 IAM 角色和权限。优先使用预定义角色，必要时创建自定义角色。
    * **服务账号管理**: 为每个需要访问 GCP 资源的应用或服务（如 Cloud Functions/Run, 或需要代表应用调用GCP API的Cloudflare Worker）创建专用的服务账号。避免使用用户凭证或默认服务账号。
    * 定期轮换服务账号密钥（如果手动管理密钥文件的话，但更推荐使用 workload identity federation 或短期凭证）。
- **Google Cloud Identity Platform (GCIP)**:
    * 启用多因素认证 (MFA) 以增强用户账户安全。
    * 配置严格的密码策略。
    * 监控可疑登录活动。
- **Pub/Sub 安全**:
    * 通过 IAM 控制对主题和订阅的访问权限（谁可以发布，谁可以订阅）。
    * (可选) 如果消息内容敏感，考虑在应用层面进行加密/解密。
- **Cloud Functions / Cloud Run 安全**:
    * **最小权限服务账号**: 为每个 Function/Service 配置具有最小权限的服务账号。
    * **入口控制**: 如果是 HTTP 触发的 Function/Run，配置其调用权限（例如，只允许通过身份验证的用户或特定服务账号调用）。
    * **依赖项安全**: 保持运行时环境和依赖库的更新。
    * **输入验证**: 对所有输入（Pub/Sub 消息负载，HTTP 请求参数）进行严格验证。
- **Firestore / Datastore 安全**:
    * **安全规则 (Security Rules)**: 为 Firestore/Datastore 配置详细的安全规则，基于用户身份 (GCIP UID) 或角色控制对数据的读写权限。
    * **服务器端验证**: 不要仅依赖客户端的安全规则，重要的业务逻辑和数据校验应在后端服务中执行。
- **Cloud Storage (GCS) 安全**:
    * **存储桶和对象ACL/IAM**: 使用 IAM 和/或访问控制列表 (ACL) 精细控制对 GCS 存储桶和对象的访问权限。默认设为私有。
    * **数据加密**: 利用 GCS 提供的服务器端加密（默认开启）或客户管理的加密密钥 (CMEK)。
- **Secret Manager**:
    * 存储所有 GCP 服务运行时需要的 API 密钥、数据库凭证、第三方服务密钥等。
    * 应用通过 IAM 授权的服务账号在运行时安全地拉取这些密钥。
- **VPC Service Controls (高级)**:
    * (可选，适用于更复杂的项目) 使用 VPC Service Controls 为 GCP 服务建立安全边界，防止数据渗漏。
- **Logging & Monitoring**:
    * 收集所有 GCP 服务的审计日志和访问日志到 Cloud Logging。
    * 在 Cloud Monitoring 中配置安全相关的告警 (例如，IAM 权限变更，可疑的 API 调用模式，Pub/Sub 死信队列消息堆积)。

---

## 🌍 六、多云环境通用安全

- **TraceID**: 确保 TraceID 在 Vercel 前端、Cloudflare Worker 和 GCP 服务之间的调用链中正确传递，以便于安全事件的追踪和溯源。
- **凭证管理**: 统一规划和审计所有平台（GitHub, Vercel, Cloudflare, GCP）的凭证、API密钥和访问令牌的生命周期管理。
- **定期安全评估**: 定期对整个多云架构进行安全风险评估和渗透测试（如果适用）。

---

## ✅ 七、安全实践核对清单 (Security Checklist)
本清单为 iN 项目的核心安全措施，应在项目各阶段（设计、开发、部署、运维）持续核对和落实。

### 🔑 身份与访问管理 (IAM)
- **[ ] 用户认证**:
    - [ ] **GCP Identity Platform (GCIP)** 已配置并启用，用于用户注册和登录。
    - [ ] 支持至少一种 OAuth 提供商 (如 Google, GitHub)。
    - [ ] （可选）为 GCIP 用户启用多因素认证 (MFA)。
- **[ ] 服务账号 (GCP & Cloudflare)**:
    - [ ] 所有 GCP 服务使用具有最小权限的专用服务账号。
    - [ ] Cloudflare Workers 访问 GCP 服务时，使用专用的 GCP 服务账号凭证。
- **[ ] IAM 权限 (GCP & Cloudflare)**:
    - [ ] 所有用户和服务账号均遵循最小权限原则。
    - [ ] 定期审查 IAM 策略。
- **[ ] API 认证**:
    - [ ] Cloudflare API Gateway 强制验证所有入站请求的 GCIP ID Token。

### 🔒 密钥与配置管理
- **[ ] 敏感信息存储**:
    - [ ] **严禁**在代码仓库中硬编码任何敏感凭证。
    - [ ] 使用 GitHub Actions Secrets, Vercel Environment Variables, Cloudflare Secrets, GCP Secret Manager 管理对应平台的密钥。
- **[ ] `.gitignore`**:
    - [ ] `.gitignore` 文件已正确配置，屏蔽所有本地敏感文件。
- **[ ] Git 历史扫描**:
    - [ ] 已完成对 Git 历史的敏感信息扫描 (Gitleaks)。
    - [ ] Gitleaks 或类似工具已集成到 GitHub Actions CI 流程。

### 🛡️ 应用与服务安全
- **[ ] 输入验证**:
    - [ ] 所有外部输入（API, Pub/Sub消息）均使用 Zod 或类似库进行严格验证。
- **[ ] 输出编码 (前端)**:
    - [ ] Vercel 前端对动态内容进行适当 HTML 编码。
- **[ ] CORS 配置**:
    - [ ] Cloudflare API Gateway 配置严格的 CORS 策略。
- **[ ] Cloudflare 安全特性**:
    - [ ] （推荐）启用 WAF 规则集。
    - [ ] （推荐）配置速率限制。
- **[ ] GCP 服务安全配置**:
    - [ ] Pub/Sub 主题/订阅 IAM 权限已配置。
    - [ ] Cloud Functions/Run 服务账号权限最小化，入口受控。
    - [ ] Firestore/Datastore 安全规则已配置。
    - [ ] GCS 存储桶权限默认私有。
- **[ ] 幂等性**:
    - [ ] 所有 GCP Pub/Sub 消费者实现幂等性处理。
- **[ ] Durable Object 安全**:
    * [ ] `TaskCoordinatorDO` 状态更新接口不可被未授权外部直接调用。

### 📦 依赖与基础设施安全
- **[ ] 依赖项管理**:
    - [ ] （推荐）使用 Dependabot 定期扫描并更新漏洞依赖。
- **[ ] 基础设施即代码 (Terraform)**:
    - [ ] Terraform 代码接受审查。
    - [ ] Terraform 状态后端安全配置。

### 📊 日志与监控
- **[ ] 日志内容安全**:
    - [ ] 所有服务日志输出均已脱敏。
    - [ ] 日志中包含 `traceId` 和 `taskId`。
- **[ ] 日志传输与存储**:
    - [ ] 日志安全传输到 GCP Cloud Logging。
- **[ ] 安全告警**:
    - [ ] 在 GCP Monitoring 中配置关键安全事件告警。

### 🔁 定期审查与流程
- **[ ] 定期安全审计**: 计划定期进行安全审查。

遵循这些安全实践和核对清单，有助于构建一个相对安全可靠的 iN 项目。