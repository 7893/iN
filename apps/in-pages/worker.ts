// /home/ubuntu/iN/apps/in/worker.ts

// 如果您的 tsconfig.json 没有自动包含 Workers 类型，可以取消下面这行的注释
// /// <reference types="@cloudflare/workers-types" />

// 定义环境变量类型，确保类型安全
// 全局类型如 Request, Response, ExecutionContext, Fetcher, RequestInit
// 应由 @cloudflare/workers-types 提供
interface Env {
  // API 服务绑定 (Fetcher 类型由 Worker 环境全局提供)
  API: Fetcher;

  // 静态资源服务绑定 (Fetcher 类型由 Worker 环境全局提供)
  // 通常由 wrangler.toml 中的 [site] 配置隐式提供
  // 如果 wrangler 确实将其作为 env.ASSET_SERVER 提供，Fetcher 类型是正确的
  ASSET_SERVER: Fetcher;

  // 在 wrangler.toml 中定义的其他 [vars] 或 secrets 也在此处添加类型
  // MY_VAR: string;
  // JWT_SECRET: string; // 例如，如果此 Worker 需要访问 secret
}

export default {
  // 使用 _ctx 来表示 ctx 参数在此函数中未被使用，消除 unused-vars 警告
  async fetch(request: Request, env: Env, _ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);

    // 检查请求路径是否以 /api/ 开头
    if (url.pathname.startsWith('/api/')) {
      console.log(`Proxying API request for: ${url.pathname}`);
      try {
        // 使用服务绑定转发请求到后端 API Worker
        return await env.API.fetch(new Request(request));
      } catch (error: unknown) { // 使用 unknown 替代 any，更类型安全
        // 对捕获的未知错误进行类型收窄，以便安全地访问属性
        const errorMessage = error instanceof Error ? error.message : String(error);
        console.error(`Error fetching from API service binding: ${errorMessage}`);
        // 可以选择性地记录完整错误对象，但要注意可能的大小
        // console.error(error);
        return new Response('API service fetch failed', { status: 500 });
      }
    }

    // 如果不是 API 请求，则假定请求静态资源
    console.log(`Serving static asset for: ${url.pathname}`);
    try {
      // 使用 ASSET_SERVER 绑定 (通常来自 [site] 配置) 获取静态文件
      return await env.ASSET_SERVER.fetch(request);
    } catch (error: unknown) { // 使用 unknown 替代 any
      // 类型收窄
      const errorMessage = error instanceof Error ? error.message : String(error);
      console.error(`Error fetching from ASSET_SERVER: ${errorMessage}`);
      // 可以选择性地记录完整错误对象
      // console.error(error);
      // ASSET_SERVER 通常会处理 404，这里捕获的是更严重的错误
      return new Response('Static asset fetch failed', { status: 500 });
    }
  },
};

// --- 移除自定义的接口定义 ---
// 下面这些接口 (Fetcher, ExecutionContext) 和类型 (RequestInit)
// 通常由 @cloudflare/workers-types 全局提供。
// 在这里重新定义是不必要的，并且可能导致类型冲突或 "not defined" 错误。
/*
interface Fetcher {
    fetch(request: Request | string, init?: RequestInit): Promise<Response>;
}

interface ExecutionContext {
    waitUntil(promise: Promise<any>): void;
    passThroughOnException(): void;
}
*/