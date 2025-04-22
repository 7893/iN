# 📄 project-overview-20250422.md
📅 Updated: 2025-04-22

## 项目简介

iN 是一个面向现代软件工程实践的图像处理与智能索引系统，目标是完整演示 Serverless 架构、事件驱动机制、Durable Object 状态机、结构化日志、自动化 CI/CD、基础设施即代码（IaC）等核心能力。

该项目为 **非商业化产品**，以单人开发的工程探索为目标，不追求大规模并发、租户隔离或商业级插件能力。

## 当前架构概览

- Cloudflare 为主平台，使用 DO、R2、D1、Vectorize 等资源。
- Vercel 负责前端展示（通过 Cloudflare Pages 或 Edge Functions 可切换）。
- Firebase 仅承担辅助性任务（如认证配置）。

## 当前状态

- 架构与命名体系稳定，基础资源已通过 Terraform 定义。
- 核心流程（图片下载→元数据→AI 向量）链路设计明确，逻辑尚在编写中。
