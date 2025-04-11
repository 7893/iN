# ~/iN/infra/logpush/main.tf (或 logpush.tf)

resource "cloudflare_logpush_job" "main" {
  # 根据是否提供 zone_id 来决定是账户级还是区域级 Job
  # count = var.cloudflare_zone_id == null ? 1 : 0 # Account-level
  account_id = var.cloudflare_account_id # 总是需要 Account ID

  # count = var.cloudflare_zone_id != null ? 1 : 0 # Zone-level
  # zone_id = var.cloudflare_zone_id

  name = var.job_name

  dataset = var.dataset

  destination_conf = var.destination_conf

  enabled = true # 默认启用

  # 可选：添加 ownership challenge (首次设置到某目的地时需要)
  # ownership_challenge = file("<path_to_challenge_file>")

  # 可选：输出选项
  # output_options { ... }

  # 可选：过滤器
  # filter = jsonencode({ ... })
}