// 文件名: eslint.config.js (通常放在项目根目录 ~/iN/)

import js from "@eslint/js";
import globals from "globals";
import parser from "@typescript-eslint/parser";
import tsPlugin from "@typescript-eslint/eslint-plugin";

export default [
  {
    files: ["**/*.ts", "**/*.tsx"], // 应用于所有 TS 和 TSX 文件
    languageOptions: {
      parser, // 使用 @typescript-eslint/parser
      parserOptions: {
        ecmaVersion: "latest", // 使用最新的 ECMAScript 标准
        sourceType: "module",  // 使用 ES Modules
      },
      globals: {
        // --- 合并基础的全局变量 ---
        ...globals.node,    // 添加 Node.js 全局变量 (如 console, process)
        ...globals.browser, // 添加浏览器全局变量 (如 fetch, setTimeout, Request, Response, URL 等)

        // --- 明确添加 Cloudflare Workers 特有的或常用的全局变量 ---
        // (即使部分可能已包含在 globals.browser 中，显式列出更清晰)
        DurableObject: "readonly",
        DurableObjectNamespace: "readonly",
        DurableObjectState: "readonly",
        ExecutionContext: "readonly",
        FetchEvent: "readonly",         // 用于非 Module Worker 或 ScheduledEvent
        Fetcher: "readonly",            // <--- 添加，用于 Service Bindings (解决 'Fetcher is not defined')
        Request: "readonly",            // Web 标准
        Response: "readonly",           // Web 标准
        Headers: "readonly",            // Web 标准
        URL: "readonly",                // Web 标准
        URLSearchParams: "readonly",    // Web 标准
        crypto: "readonly",             // Web Crypto API
        ReadableStream: "readonly",     // Web 标准
        WritableStream: "readonly",     // Web 标准
        TransformStream: "readonly",    // Web 标准

        // --- 根据需要可以添加其他 Cloudflare 绑定类型作为全局变量 ---
        // --- (但通常更推荐在 Env 接口中定义绑定类型) ---
        // R2Bucket: "readonly",
        // D1Database: "readonly",
        // Queue: "readonly",
        // VectorizeIndex: "readonly",
        // KVNamespace: "readonly",
        // Ai: "readonly", // Worker AI binding
      },
    },
    plugins: {
      "@typescript-eslint": tsPlugin, // 加载 TypeScript 插件
    },
    rules: {
      // --- 继承推荐规则集 ---
      ...js.configs.recommended.rules,      // ESLint JavaScript 推荐规则
      ...tsPlugin.configs.recommended.rules, // TypeScript 推荐规则

      // --- 自定义或覆盖规则 ---
      // 忽略下划线开头未使用的变量（如 _request, _env, _ctx）
      "@typescript-eslint/no-unused-vars": ["error", {
        "argsIgnorePattern": "^_", // 忽略以下划线开头的函数参数
        "varsIgnorePattern": "^_"  // 忽略以下划线开头的变量
      }],

      // 允许空 interface（例如: interface Env {}）
      "@typescript-eslint/no-empty-interface": "off",

      // (可选) 根据团队偏好添加或修改其他规则
      // "indent": ["error", 2], // 例如：强制 2 个空格缩进
      // "@typescript-eslint/no-explicit-any": "warn", // 例如：将禁止 any 降级为警告
    },
  },
];