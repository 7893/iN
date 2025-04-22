# 📄 ci-structure-20250422.md
📅 Updated: 2025-04-22

## 当前 CI/CD 概况

- 使用 GitLab CI
- 阶段划分：Lint → Test → Build → Deploy → Terraform Apply（未来计划）
- 项目采用 Monorepo 结构，CI 结合 Turborepo 执行子任务调度

## 协作预留建议（未来）

- 引入分支保护策略：main/dev 禁止直接 push，需通过 MR 审查
- 设定 Reviewer 审批逻辑（如至少 1 人 Review 才允许合并）
- 集成 Secrets 检查、依赖扫描、Terraform Plan 自动审批
