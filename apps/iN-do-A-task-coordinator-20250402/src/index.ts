// ~/iN/apps/iN-do-A-task-coordinator-20250402/src/index.ts

// 确保 Worker 类型可用 (如果 tsconfig.json 未完全配置好)
// /// <reference types="@cloudflare/workers-types" />

// 定义 Env 类型，至少包含 DO 自身的绑定 (如果需要内部调用)
// 后续可以添加此 DO 需要访问的其他绑定 (如 D1, R2, Queues, Secrets)
interface Env {
  TASK_COORDINATOR_DO: DurableObjectNamespace;
  // Example: DB: D1Database;
  // Example: MY_SECRET: string;
}

// 定义 TaskCoordinatorDO 类，实现 DurableObject 接口
export class TaskCoordinatorDO implements DurableObject {
  state: DurableObjectState;
  env: Env;
  initialized: boolean;

  constructor(state: DurableObjectState, env: Env) {
    this.state = state;
    this.env = env;
    this.initialized = false;

    // 可以在构造函数中进行一次性初始化设置，例如从存储中加载初始状态
    // 但要注意构造函数在对象首次创建或唤醒时都可能执行
    // this.initialize(); // Consider lazy initialization in fetch instead
  }

  // 可选的初始化函数 (如果需要在首次 fetch 时执行)
  async initialize() {
    // 例如: let initialStatus = await this.state.storage.get("status");
    // if (initialStatus === undefined) {
    //   await this.state.storage.put("status", "PENDING");
    // }
    this.initialized = true;
    console.log("TaskCoordinatorDO initialized.");
  }

  // fetch 处理函数 - 这是 DO 与外界交互的主要入口
  // 即使这个脚本主要是为了定义 DO 类以创建 Namespace，
  // 它仍然需要一个 fetch 处理程序才能被成功部署。
  async fetch(request: Request): Promise<Response> {
    // 对于这个主要用于定义 DO 的脚本，fetch 可能很简单
    // 可以返回一个简单的确认信息，或者根据需要处理特定的管理请求

    // 确保初始化逻辑被调用 (如果需要)
    // if (!this.initialized) {
    //   await this.initialize();
    // }

    const url = new URL(request.url);

    // 简单示例: 可以返回一个基本信息
    if (url.pathname === "/status") {
      // 实际应用中会从 this.state.storage 获取状态
      const currentStatus = await this.state.storage.get("status") || "UNKNOWN";
      return new Response(`DO Status: ${currentStatus}`);
    }

    // 默认返回
    return new Response("TaskCoordinatorDO Definition Worker: OK");
  }

  // --- 在这里添加 DO 的核心业务逻辑方法 ---
  // 例如:
  // async updateStatus(newStatus: string): Promise<void> {
  //   await this.state.storage.put("status", newStatus);
  // }
  //
  // async getStatus(): Promise<string | undefined> {
  //   return await this.state.storage.get("status");
  // }
  // -----------------------------------------

  // --- Required DurableObject Methods (alarm) ---
  async alarm() {
    console.log("DO Alarm triggered");
    // Handle alarm logic
  }

} // End of TaskCoordinatorDO class definition


// 默认导出，包含 fetch 处理程序
// Wrangler 需要一个默认导出的对象，该对象具有 fetch 方法
export default {
  // --- 修改这里 ---
  // 给未使用的参数加上下划线前缀
  async fetch(_request: Request, _env: Env, _ctx: ExecutionContext): Promise<Response> {
    // --- 修改结束 ---

    // 对于定义 DO 的脚本，这里的 fetch 可能只是简单地返回确认
    // 或者在特定场景下用于管理或查询 DO (虽然不常见)
    // 重要的是，需要这样一个导出才能成功部署
    console.log("DO Definition Worker received fetch request (default export). Parameters unused.");
    // 注意：这个 fetch 不会直接路由到上面 DO 类的 fetch 方法。
    // 要与特定的 DO 实例交互，需要通过 DO Namespace stub。
    // 例如，另一个 Worker 会这样做：
    // let id = env.TASK_COORDINATOR_DO.idFromName("some-task-id");
    // let stub = env.TASK_COORDINATOR_DO.get(id);
    // let response = await stub.fetch(request); // 这个 request 会被路由到 DO 类的 fetch
    return new Response("DO Definition Worker: OK");
  }
};