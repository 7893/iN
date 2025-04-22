# 🔁 frontend-integration-guide-20250422.md
_向量搜索联调说明 + API 对接建议_

## 🌉 前后端联通目标

- 支持用户在前端页面发起图片查询请求
- 显示查询结果，包括 AI 分析标签、相似图片等

## ✅ API 接口

- 查询接口：`/api/image/search`
- 参数结构：
```json
{
  "query": "dog",
  "limit": 10
}
```

## 🔍 搜索类型

- 基于文本描述（调用 Vectorize + 向量索引）
- 基于相似图片（后续支持）

## 💡 联调建议

- 使用 `POST` 请求发送 query，封装成 form
- 确保传递 `traceId` 用于日志追踪
- 接口返回结构包括：
```json
{
  "results": [
    {
      "imageUrl": "...",
      "score": 0.97,
      "tags": ["dog", "animal"]
    }
  ]
}
```

## 🎨 页面建议

- 输入框 + 查询按钮
- 查询结果展示网格
- 支持 loading 状态与空结果处理

---

文件名：frontend-integration-guide-20250422.md  
生成时间：20250422
