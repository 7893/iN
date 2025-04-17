import js from "@eslint/js";
import globals from "globals";
import parser from "@typescript-eslint/parser";
import tsPlugin from "@typescript-eslint/eslint-plugin";

export default [
  {
    files: ["**/*.ts", "**/*.tsx"],
    languageOptions: {
      parser,
      parserOptions: {
        ecmaVersion: "latest",
        sourceType: "module",
      },
      globals: {
        ...globals.node,
        ...globals.browser,
        // ✅ 添加 Cloudflare Workers 环境的全局变量支持
        DurableObject: "readonly",
        DurableObjectNamespace: "readonly",
        DurableObjectState: "readonly",
        ExecutionContext: "readonly",
        FetchEvent: "readonly",
        Request: "readonly",
        Response: "readonly",
        Headers: "readonly",
      },
    },
    plugins: {
      "@typescript-eslint": tsPlugin,
    },
    rules: {
      ...js.configs.recommended.rules,
      ...tsPlugin.configs.recommended.rules,
      // ✅ 忽略下划线开头未使用的变量（如 _request, _env, _ctx）
      "@typescript-eslint/no-unused-vars": ["error", {
        "argsIgnorePattern": "^_",
        "varsIgnorePattern": "^_"
      }],
      // ✅ 允许空 interface（避免对某些类型声明报错）
      "@typescript-eslint/no-empty-interface": "off",
    },
  },
];
