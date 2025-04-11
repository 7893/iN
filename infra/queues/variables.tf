# ~/iN/infra/queues/variables.tf

variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare Account ID (passed from root module)"
}

# 这里保持简单，队列名称和DLQ阈值在 main.tf 中直接定义
# 如果需要更灵活的配置，可以在这里定义 map 类型的变量来接收配置