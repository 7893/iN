#!/bin/bash
# sync-runtime-to-cloudflare.sh
# 读取 .env.secrets 文件并将 RUNTIME_* 变量同步到 Cloudflare Secrets Store (Account Level)
#
# 前提条件:
# 1. 安装了 wrangler CLI: `npm install -g wrangler`
# 2. 已通过 `wrangler login` 登录，或者设置了 Cloudflare API 令牌环境变量 (例如 CF_API_TOKEN)
# 3. secrets 将被上传到 Cloudflare 账户级别，需要在 `wrangler.toml` 中绑定才能被特定 Worker 使用。

# 配置 (Worker 名称在此脚本中非必需，因为 secret 是账户级别的)
ACCOUNT_ID="ed3e4f0448b71302675f2b436e5e8dd3" # 替换为你的 Cloudflare 账户 ID

# 本地 .env.secrets 路径 (使用 $HOME 提高可靠性)
ENV_FILE_PATH="$HOME/iN/.env.secrets"

# 检查 .env.secrets 文件是否存在
if [ ! -f "$ENV_FILE_PATH" ]; then
  echo "错误: secrets 文件未找到: $ENV_FILE_PATH"
  exit 1
fi

echo "开始同步 RUNTIME_* secrets 到 Cloudflare 账户 $ACCOUNT_ID ..."

# 读取文件中的每一行并推送到 Cloudflare Secrets Store
while IFS='=' read -r key value || [[ -n "$key" ]]; do # `|| [[ -n "$key" ]]` 处理文件最后一行没有换行符的情况
  # 去除可能存在的回车符 (CR)
  value=$(echo "$value" | tr -d '\r')
  key=$(echo "$key" | tr -d '\r')

  if [[ $key == RUNTIME_* ]]; then
    secret_name="$key"
    echo "正在同步 secret: $secret_name ..."

    # 使用 wrangler 进行 Secret 上传，通过标准输入传递值
    # 注意：wrangler secret put 将 secret 上传到账户级别
    if echo "$value" | wrangler secret put "$secret_name"; then
      echo "成功同步 $secret_name."
    else
      echo "错误: 同步 $secret_name 失败。请检查 wrangler 输出或权限。"
      # 可以选择在这里退出脚本: exit 1
    fi
  fi
done < "$ENV_FILE_PATH"

echo "Cloudflare secrets 同步完成。"