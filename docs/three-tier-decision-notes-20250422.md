# 🧠 三元平台选型与职责划分决策记录  
📄 文档名称：three-tier-decision-notes-20250422.md  
🗓️ 更新时间：2025-04-22

---

## 🎯 背景

原始架构采用 Cloudflare 单栈实现，具备强一致性与边缘计算能力，但成本与复杂度偏高。为提升开发效率与交互体验，转为 Cloudflare + Firebase + Vercel 的“现代三元分布式架构”。

---

## 🧩 三元平台划分

| 平台 | 核心职责 | 使用组件 |
|------|------------|------------|
| ☁️ Cloudflare | 后端逻辑核心、任务流程控制 | Workers, Durable Object, Queues, R2, D1, KV, Vectorize, Logpush, AI |
| 🔐 Firebase | 用户身份认证与偏好配置 | Auth (OAuth 登录), Firestore (偏好配置存储) |
| 🎨 Vercel | 前端托管与用户交互页面 | Hosting, Preview Deployments, ENV 配置, SSR/SSG 支持 |

---

## ✅ 决策依据

- **Cloudflare**：继续作为任务状态中枢、数据处理核心，优势在于边缘分布式运行与高性能。
- **Firebase**：不承载核心处理逻辑，仅用于 OAuth 认证与 Firestore 配置（轻量非状态关键）。
- **Vercel**：仅用于 UI 渲染和页面托管，不处理任务流，最大化利用其静态部署与预览能力。

---

## 📌 使用策略总结

- Cloudflare 仍然主导系统处理链，不迁移 Durable Object、任务队列。
- Firebase 只做身份认证、preset 存储，禁用其 Cloud Functions 以避免架构分裂。
- Vercel 专注前端交互体验，使用 SvelteKit 实现 SPA 架构。

---

## 💡 经验结论

- 使用三元平台组合极大降低开发负担，加快迭代速度。
- 三者职责不交叉、互不干扰，完全可通过 ENV/Secret 管理实现无缝集成。
- 前端架构向桌面体验靠近，后端保持高性能、强一致控制，结构合理稳定。

---

# ✅ 总结

三元结构带来清晰的分工模型、优秀的性能体验与极佳的开发效率，是面向现代 Serverless 场景的最佳实践之一，适用于个人项目、中小型分布式系统或教育型架构演示项目。
