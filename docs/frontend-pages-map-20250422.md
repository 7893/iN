# 🖼️ 前端页面结构与功能映射  
📄 文档名称：frontend-pages-map-20250422  
🗓️ 更新时间：20250422  

---

## 📦 项目前端说明（in-pages）

使用 SvelteKit + TailwindCSS 开发，部署于 Vercel，构建为典型 SPA。API 接口由 Cloudflare Workers 提供，身份认证基于 Firebase。

---

## 📄 页面结构映射表

| 页面路径 | 功能 | 对应 API |
|----------|------|----------|
| `/login` | 登录页面（Firebase OAuth） | Firebase Auth |
| `/dashboard` | 用户控制台首页 | - |
| `/config` | 用户配置界面（preset 管理） | `config-api` |
| `/trigger` | 手动发起任务入口 | `config-api` 或内部调用 |
| `/status` | 当前任务状态展示（traceId/taskId） | `query-api`, `do` |
| `/image/:id` | 单图详情页（原图 + AI 分析） | `query-api` |
| `/search` | 图片搜索页（向量索引） | `vectorize + query-api` |
| `/logtrace/:traceId` | 日志链路查看器（可选） | Axiom 查询嵌入 |

---

## 🧩 全局组件与封装建议

- `lib/api.ts`: 所有 fetch 封装，注入 Auth Token、traceId
- `lib/auth.ts`: Firebase Session 管理
- `lib/ui/`: Tailwind UI 封装组件

---

# ✅ 总结

结构清晰、接口集中、行为分离是前端架构主旨，重点在于对接后端状态流与任务链，强化 traceId 驱动交互。
