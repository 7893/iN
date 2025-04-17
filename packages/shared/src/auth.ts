// packages/shared/src/auth.ts

import { jwtVerify, type JWTVerifyResult, type JWTPayload } from 'jose'; // 使用 'jose' 处理 JWT
import { createHmac } from 'crypto'; // 使用 Node.js crypto 处理 HMAC (Workers 环境可用)

// --- 配置 ---
// 密钥应通过 Worker 环境变量绑定从 Secrets Store 传入，此处不应硬编码或直接读取 env

// --- 类型定义 ---

/**
 * 认证成功后解析出的用户上下文信息
 * !!! 请根据您的 JWT 实际载荷结构进行调整 !!!
 */
export interface AuthUserContext {
    userId: string; // 用户的唯一标识符
    // 可以添加其他需要的用户信息，例如：
    // roles?: string[]; // 用户角色
    // tenantId?: string; // 租户 ID (如果支持多租户)
}

/**
 * 认证结果类型
 */
export type AuthResult =
    | { success: true; userContext: AuthUserContext } // 成功，包含用户上下文
    | { success: false; error: string }; // 失败，包含错误信息

// --- JWT 验证 ---

/**
 * 验证 JWT (JSON Web Token)。
 *
 * @param token - 从请求头中提取的 JWT 字符串。
 * @param secret - 用于验证签名的密钥。对于对称算法，通常是字符串或 Uint8Array；对于非对称算法，是公钥。
 * 使用 'jose' 时，对称密钥推荐使用 Uint8Array。
 * @param expectedIssuer - (可选) 期望的签发者 (iss claim)。
 * @param expectedAudience - (可选) 期望的受众 (aud claim)。
 * @returns AuthResult 对象，成功时包含用户上下文，失败时包含错误信息。
 */
export async function verifyJwt(
    token: string | undefined | null,
    secret: Uint8Array | string,
    expectedIssuer?: string,
    expectedAudience?: string
): Promise<AuthResult> {
    if (!token) {
        return { success: false, error: 'Missing JWT token' };
    }

    try {
        // 如果传入的 secret 是字符串，需要转换为 Uint8Array 供 jose 使用（对称加密场景）
        const secretKey = typeof secret === 'string' ? new TextEncoder().encode(secret) : secret;

        // 配置验证选项
        const options: { issuer?: string; audience?: string } = {};
        if (expectedIssuer) {
            options.issuer = expectedIssuer;
        }
        if (expectedAudience) {
            options.audience = expectedAudience;
        }

        // 使用 jose 进行验证
        const { payload }: JWTVerifyResult<JWTPayload> = await jwtVerify(
            token,
            secretKey,
            options // 传入验证选项
        );

        // --- 从 JWT 载荷 (payload) 中提取用户信息 ---
        // !!! 关键: 请根据您的实际 JWT 载荷结构调整此部分逻辑 !!!
        // 常见的用户标识字段有 'sub' (Subject), 'userId', 'id' 等
        const userId = payload.sub ?? payload.userId ?? payload.id as string | undefined;

        if (!userId) {
            // 如果 JWT 中缺少必要的用户标识，应视为验证失败
            console.error("JWT payload missing required user identifier (e.g., sub, userId, id)", payload);
            return { success: false, error: 'Invalid JWT payload: Missing user identifier' };
        }

        // 这里可以添加对其他必须存在的声明 (claims) 的校验

        // 构建用户上下文
        const userContext: AuthUserContext = {
            userId: userId,
            // 根据需要从 payload 中提取其他信息, 例如:
            // roles: payload.roles as string[] | undefined,
        };

        return { success: true, userContext: userContext };

    } catch (error: unknown) {
        // 处理 jose 可能抛出的特定错误
        let errorMessage = 'Invalid JWT token';
        if (error instanceof Error) {
            if (error.name === 'JWTExpired') {
                errorMessage = 'JWT token has expired';
            } else if (error.name === 'JWTClaimValidationFailed') {
                errorMessage = `JWT claim validation failed: ${error.message}`;
            } else if (error.name === 'JWSSignatureVerificationFailed') {
                errorMessage = 'JWT signature verification failed';
            }
            // 可以根据需要添加更多 'jose' 错误类型的判断
            console.error(`JWT Verification Error (${error.name}): ${error.message}`);
        } else {
            console.error('Unknown JWT Verification Error:', error);
        }
        return { success: false, error: errorMessage };
    }
}

// --- HMAC 验证 ---

/**
 * 验证 HMAC (Hash-based Message Authentication Code) 签名。
 * 通常用于验证 Webhook 请求或简单的 API 密钥签名。
 *
 * @param secret - 用于计算 HMAC 的密钥 (字符串)。
 * @param message - 用于生成签名的消息内容 (通常是请求体或特定部分的组合)。
 * @param providedSignature - 请求中提供的签名 (例如，从 'X-Signature' 请求头获取)。
 * @param algorithm - HMAC 算法，默认为 'sha256'。其他如 'sha1', 'sha512'。
 * @returns 如果签名有效返回 true，否则返回 false。
 */
export function verifyHmac(
    secret: string,
    message: string,
    providedSignature: string | undefined | null,
    algorithm: string = 'sha256'
): boolean {
    // 必须提供签名、密钥和消息内容
    if (!providedSignature || !secret || message === undefined || message === null) {
        // 可以根据需要添加日志记录
        return false;
    }

    try {
        // 使用 Node.js crypto 计算预期的 HMAC 签名
        const hmac = createHmac(algorithm, secret);
        hmac.update(message);
        const expectedSignature = hmac.digest('hex'); // 通常签名是十六进制表示

        // --- 安全比较 ---
        // 简单的字符串比较在大多数情况下可行。
        // 更严格的安全场景推荐使用固定时间比较（timing-safe comparison），
        // 但 Node.js 的 crypto.timingSafeEqual 要求 Buffer 且长度一致。
        if (providedSignature.length !== expectedSignature.length) {
            return false; // 长度不同，肯定不匹配
        }
        // 暂时使用简单比较
        return providedSignature === expectedSignature;

        /* 使用 timingSafeEqual 的示例 (需要 Buffer 转换和长度检查):
        try {
          const providedBuf = Buffer.from(providedSignature, 'hex'); // 假设签名是 hex 编码
          const expectedBuf = Buffer.from(expectedSignature, 'hex');
          // timingSafeEqual 要求 Buffer 长度必须完全一致
          if (providedBuf.length !== expectedBuf.length) {
              return false;
          }
          return crypto.timingSafeEqual(providedBuf, expectedBuf);
        } catch (bufferError) {
          // 处理无效的 hex 编码等错误
          console.error('Error comparing HMAC signatures:', bufferError);
          return false;
        }
        */

    } catch (error) {
        // 处理 crypto 操作可能发生的错误
        console.error('HMAC Verification Error:', error);
        return false;
    }
}

// --- 辅助函数：从 Authorization 头提取 Bearer Token ---

/**
 * 从 Authorization 请求头中提取 Bearer Token。
 * @param headers - 请求头对象 (Headers)。
 * @returns Token 字符串，如果找不到或格式不正确则返回 null。
 */
export function getBearerToken(headers: Headers): string | null {
    const authorization = headers.get('Authorization');
    if (!authorization) {
        return null; // 没有 Authorization 头
    }
    const parts = authorization.split(' '); // 按空格分割
    // 检查是否为两部分，且第一部分是 'Bearer' (不区分大小写)
    if (parts.length === 2 && parts[0].toLowerCase() === 'bearer') {
        return parts[1]; // 返回 Token 部分
    }
    return null; // 格式不正确
}

// --- 如何在 Worker 中使用 (示例) ---
/*
// 在您的 Worker 文件中 (例如: api-gateway-worker)
import { verifyJwt, getBearerToken, type AuthResult } from '../packages/shared/src/auth'; // 调整路径

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {

    // --- JWT 验证示例 ---
    const token = getBearerToken(request.headers); // 从请求头获取 Token

    // 假设 JWT_SECRET 密钥通过 wrangler.toml 绑定到了 env 对象
    const jwtSecret = env.JWT_SECRET;
    if (!jwtSecret) {
      // 必须配置密钥才能进行验证
      return new Response('Server configuration error: JWT secret missing', { status: 500 });
    }

    // 调用验证函数
    const authResult: AuthResult = await verifyJwt(
        token,
        jwtSecret, // 传入密钥
        // 如果需要，传入 issuer 和 audience 进行校验
        // env.JWT_ISSUER,
        // env.JWT_AUDIENCE
    );

    // 检查验证结果
    if (!authResult.success) {
      // 验证失败，返回 401 未授权
      return new Response(`Authentication failed: ${authResult.error}`, { status: 401 });
    }

    // 验证成功，可以使用用户信息
    console.log(`User authenticated: ${authResult.userContext.userId}`);
    // 后续可以将 authResult.userContext 传递给下游服务或用于授权判断

    // --- HMAC 验证示例 (例如用于特定的 Webhook 接口) ---
    // if (request.url.endsWith('/webhook')) {
    //   // 假设请求体是消息内容，签名在 X-Signature 头中
    //   const requestBody = await request.text();
    //   const signature = request.headers.get('X-Signature');
    //   // 假设 Webhook 密钥通过 wrangler.toml 绑定到了 env 对象
    //   const hmacSecret = env.WEBHOOK_SECRET;
    //   if (hmacSecret && !verifyHmac(hmacSecret, requestBody, signature)) {
    //     // HMAC 验证失败，返回 403 禁止访问
    //     return new Response('Invalid signature', { status: 403 });
    //   }
    //   // HMAC 验证成功，处理 Webhook 逻辑...
    // }


    // 继续处理请求...
    return new Response(`Hello user ${authResult.userContext.userId}! Welcome.`);
  },
};
*/