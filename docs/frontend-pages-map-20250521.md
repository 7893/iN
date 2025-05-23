# 📄 frontend-pages-map-20250521.md (架构版本 2025年5月21日)
📅 Updated: 2025-05-21

## 当前前端应用 (部署于 Vercel) 页面结构规划

| 页面路径 (示例) | 功能描述                                                    | 是否 MVP 目标 | 状态     | 备注                                                                   |
| --------------- | ----------------------------------------------------------- | ------------- | -------- | ---------------------------------------------------------------------- |
| `/`             | 应用首页 / 仪表盘 / 最近任务概览                              | ✅ 是         | 计划中   | 用户登录后可见，展示一些关键信息或导航。                                   |
| `/auth/login`   | 用户登录页面                                                | ✅ 是         | 计划中   | 集成 Google Cloud Identity Platform (GCIP) 实现多种登录方式。        |
| `/auth/signup`  | 用户注册页面 (如果GCIP配置允许邮箱注册)                       | ✅ 是         | 计划中   |                                                                        |
| `/dashboard`    | 用户仪表盘 / 任务列表页                                     | ✅ 是         | 计划中   | 显示用户创建的任务列表、状态、创建时间等，支持分页、筛选、排序。           |
| `/tasks/new`    | 新建任务 / 配置编辑页 | ✅ 是         | 计划中   | 用户在此配置图像源、处理选项等，并发起新的图像处理任务。                   |
| `/tasks/{taskId}` | 任务详情页                                                  | ✅ 是         | 计划中   | 显示特定任务的详细处理进度、各阶段状态、最终结果（预览图、元数据、AI标签）。 |
| `/search`       | 图像向量搜索界面  | ✅ (MVP 后期) | 计划中   | 用户输入文本描述，搜索相似图片，展示搜索结果。                               |
| `/settings`     | 用户个人设置页面                                            | 🟡 否 (可选)  | 待定     | 例如修改用户偏好、API密钥管理（如果允许用户自带AI Key等）。                |
| `/docs/api`     | (可选) API 文档页面 (如果提供公开API给开发者)                 | ❌ 否         | 待定     |                                                                        |
| `/admin`        | (可选) 管理后台页面 (如果需要系统管理功能)                    | ❌ 否         | 待定     |                                                                        |

## 路由与访问控制说明

- 大部分页面 (如 `/dashboard`, `/tasks/*`, `/search`, `/settings`) 需要用户登录后才能访问。通过前端路由守卫和 GCIP 认证状态进行控制。
- `/auth/*` 路径用于处理未登录用户的认证流程。
- 页面组件化程度应较高，便于复用和维护。

## 限制与建议 (基于 `frontend-pages-map-20250422.md`)

- **MVP 阶段页面数量控制**: 建议 MVP 阶段核心页面数量限制在 3-5 个以内，聚焦核心用户流程，便于逻辑集中与资源聚焦。
- **组件嵌套层级**: 每个页面建议组件嵌套不超过 3-4 层，以保持代码可读性和维护性。
- **响应式设计**: 所有页面均需考虑响应式设计，适配不同屏幕尺寸（桌面、平板、移动设备）。
- **可访问性 (A11y)**: 开发时应遵循基本的 Web 可访问性标准。

此页面地图规划了在 Vercel 上运行的前端应用的主要用户界面和导航结构，服务于核心的图像处理任务配置、状态跟踪和结果展示功能。