# 📊 Cloudflare Logpush 接入 Axiom 指南  
📄 文档名称：logpush-axiom-guide-20250422  
🗓️ 更新时间：20250422  

---

## 🎯 目标

通过结构化日志输出 + Cloudflare Logpush，实现 iN 项目的日志链路接入 Axiom，实现可追踪、可聚合、可告警的日志系统。

---

## 📦 步骤一：日志结构设计

使用 `packages/shared-libs/logger.ts` 统一输出格式：

```ts
{
  level: 'info' | 'warn' | 'error'
  message: string
  traceId?: string
  taskId?: string
  worker: string
  timestamp: string
  ...context // 业务上下文字段
}
```

---

## 🛠️ 步骤二：Logpush 设置

1. Terraform 中定义 logpush 配置（或控制台启用）
2. 目标类型选择：HTTPS Logpush Destination
3. Axiom 创建 Dataset + Token
4. Logpush 配置中设置 Headers（携带 Axiom Token）

---

## 🔎 步骤三：验证与可视化

- 使用 Axiom 查询 traceId 或 taskId 查看链路日志
- 配置 Dashboard：
  - Worker 执行错误率
  - 每阶段耗时
  - DLQ 消费统计
- 配置告警规则：
  - 错误率 >5%
  - 单阶段耗时异常
  - DLQ 非空

---

## ✅ 推荐策略

- 本地 logger 输出 → Logpush → Axiom
- 不需额外存储/中转，直接接入并聚合分析
- 每个 traceId 为最小观察单位
