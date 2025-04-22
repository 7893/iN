# 🚀 iN Project – Intelligent Image Infrastructure on Cloudflare

> 构建于 Cloudflare 的现代智能图像处理系统  
> 聚焦 Serverless 架构、事件驱动模型、Durable Object 状态管理与可观测性实践

---

## 🎯 项目定位

本项目为 **个人主导的现代软件工程范式实践项目**，聚焦探索并落地以下关键能力：

- 云原生 Serverless 架构（Cloudflare 全家桶）
- 分布式异步任务流与事件驱动解耦
- Durable Object 状态协调机制
- 全链路结构化日志与可观测性构建
- 基础设施即代码（Terraform）与自动化 CI/CD 实践

👉 项目目标 **不是商业化产品**，而是对“现代架构 + 工程能力”的一次 **系统性演练**。

---

## 📦 技术架构概览

| 层级 | 技术组件 | 说明 |
|------|------------|------|
| **前端** | Vercel + Cloudflare Pages | 托管配置与展示页面 |
| **接口层** | Cloudflare Workers | API 网关、配置、查询等 |
| **主处理链** | Durable Object + Queues + Workers | 下载 → 元数据 → AI 向量 |
| **存储** | R2（图片）、D1（结构化数据）、Vectorize（向量） | 多模态数据存储 |
| **认证** | Firebase Auth | 用户身份验证与访问控制 |
| **可观测性** | Logpush + Axiom + TraceId | 日志、追踪与告警机制 |
| **IaC 与部署** | Terraform + GitLab CI | 所有资源与部署流程基础设施化管理 |

---

## 🔨 当前 MVP 范围

- ✅ 原图上传与采集任务发起  
- ✅ 下载 → 元数据提取 → AI 向量处理 三段式处理链  
- ✅ 向量存储 + 基本查询 API  
- ✅ 配置 UI（Vercel 前端）与状态展示接口联调  
- ✅ Logpush + Axiom 可观测性打通

---

## 🧠 项目亮点

- 🌍 三元架构（CF 主干，VC 展示，FB 辅助）简明高效
- ⚙️ Durable Object 状态协调驱动任务流程稳定演进
- ✨ 所有代码、文档均由 **生成式人工智能（ChatGPT, Gemini, Grok）协作完成**
- 📚 全套工程文档位于 [`/docs/`](./docs) 目录，覆盖从命名规范到测试策略

---

## 📁 仓库结构简览

```
├── apps/              # 所有前端 + Worker 应用
├── packages/          # 共享库与逻辑封装
├── infra/             # Terraform 定义与资源输出
├── tools/             # 密钥同步与清理脚本
├── docs/              # 架构与工程文档全集
├── README.md
└── turbo.json         # Turborepo 构建策略
```

---

## 🔗 开发指南

```bash
# 克隆并安装依赖
git clone <repo-url>
cd in
pnpm install

# 启动本地 Worker 进行开发调试
cd apps/iN-worker-d-download-20250402
wrangler dev
```

> 如需完整开发计划，请参见 [`docs/phased-implementation-*.md`](./docs/phased-implementation-20250422.md)

---

🕒 更新时间：2025-04-22  
✍️ 全部由 AI（ChatGPT, Gemini, Grok）协作生成并持续完善
