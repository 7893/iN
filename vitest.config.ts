// ~/iN/vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    // 在这里可以放其他的 Vitest 配置，例如：
    globals: true,       // 启用全局 API (describe, it, expect 等)
    environment: 'node', // 指定测试环境 (根据需要选择 'node', 'jsdom' 等)
    // ... 其他配置 ...
  },
  deps: {
    // 保留之前的尝试，或者只用下面的 ssr 配置可能也行，但保留通常无害
    inline: [
      'nanoid',
    ],
  },
  // --- 添加 ssr.noExternal 配置 ---
  // 即使不是 SSR 测试，Vitest 在 Node 环境下可能使用 Vite 的 SSR 管道
  // noExternal 强制 Vitest/Vite 处理这个依赖，而不是视为外部依赖
  ssr: {
    noExternal: ['nanoid'],
  },
});