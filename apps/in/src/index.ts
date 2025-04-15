// ~/iN/apps/in/src/index.ts
export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    // Wrangler 在处理 [site] 配置时，通常会自动处理静态文件请求。
    // 这个 fetch 函数可以留空，或用于处理 API 代理、特定路径逻辑等。
    // 返回一个简单的响应作为后备。
    return new Response("Frontend Worker is active. Static content should be served from the 'bucket'.", { status: 200 });
  },
};
interface Env {
  // 添加此 Worker 需要的绑定类型
  // API: Fetcher; // Service binding example
}
