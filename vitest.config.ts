// ~/iN/vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    // 在这里可以放其他的 Vitest 配置，例如：
    globals: true,       // 启用全局 API (describe, it, expect 等)
    environment: 'node', // 指定测试环境 (根据需要选择 'node', 'jsdom' 等)
    // ... 其他配置 ...
  },
  // --- 关键：添加 deps.inline 配置 ---
  deps: {
    inline: [
      'nanoid', // 告诉 Vitest 内联处理 nanoid
    ],
  },
});
