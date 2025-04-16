// /home/ubuntu/iN/apps/in/worker.ts

// 定义环境变量类型，确保类型安全
interface Env {
  // API 服务绑定 (来自 wrangler.toml 的 [[services]])
  API: Fetcher;

  // 静态资源服务绑定 (由 Wrangler 在配置了 [site] 时隐式提供)
  ASSET_SERVER: Fetcher;

  // 如果您在 wrangler.toml 中定义了 [vars] 或 secrets，也在这里添加类型
  // MY_VAR: string;
}

export default {
  // fetch 处理函数是 Worker 的核心入口
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    // 解析请求 URL
    const url = new URL(request.url);

    // 检查请求路径是否以 /api/ 开头，如果是，则代理到后端 API Worker
    if (url.pathname.startsWith('/api/')) {
      console.log(`Proxying API request for: ${url.pathname}`);
      try {
        // 直接使用 env.API (服务绑定) 来转发请求
        // 使用 new Request(request) 可以较好地复制原始请求的方法、头部、主体等
        return await env.API.fetch(new Request(request));
      } catch (error: any) {
        console.error(`Error fetching from API service binding: ${error.message}`);
        return new Response('API service fetch failed', { status: 500 });
      }
    }

    // 如果请求路径不是 /api/ 开头，则假定是请求静态资源 (HTML, JS, CSS, 图片等)
    // 使用 env.ASSET_SERVER (由 [site] 配置提供) 来获取并返回静态文件
    console.log(`Serving static asset for: ${url.pathname}`);
    try {
      // ASSET_SERVER 会根据请求路径查找 ./dist 目录中的文件
      return await env.ASSET_SERVER.fetch(request);
    } catch (error: any) {
      console.error(`Error fetching from ASSET_SERVER: ${error.message}`);
      // 可以在这里返回自定义的 404 页面，或者直接返回错误
      // ASSET_SERVER 默认会处理 404，这里捕获的是更严重的错误
      return new Response('Static asset fetch failed', { status: 500 });
    }
  },
};

// 定义 Fetcher 接口，用于类型提示
interface Fetcher {
    fetch(request: Request | string, init?: RequestInit): Promise<Response>;
}

// 定义 ExecutionContext 接口 (如果需要使用 ctx.waitUntil 等)
interface ExecutionContext {
    waitUntil(promise: Promise<any>): void;
    passThroughOnException(): void;
}
