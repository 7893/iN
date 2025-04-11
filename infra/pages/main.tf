# ~/iN/infra/pages/main.tf (或 pages.tf) - 已修正 GitLab source config

resource "cloudflare_pages_project" "frontend" {
  account_id        = var.cloudflare_account_id
  name              = var.project_name # "in-pages"
  production_branch = var.production_branch

  source {
    type = "gitlab" # 指定类型为 gitlab
    config {
      # --- 修正这里的参数 ---
      repo_name         = var.gitlab_project_name   # 使用 repo_name 对应 GitLab 项目名称
      owner             = var.gitlab_owner          # GitLab 用户名或组名
      production_branch = var.production_branch
      # 移除了 project_id
      # --------------------
    }
  }

  # 可选：配置构建设置
  # build_config {
  #   build_command   = "npm run build" # TODO: 替换为您的构建命令
  #   destination_dir = "dist"          # TODO: 替换为构建输出目录
  # }

  # 可选：配置环境变量等
  # deployment_configs { ... }
}

# --- 可选输出 ---
# output "pages_url" {
#   description = "The URL of the deployed Pages project"
#   value       = cloudflare_pages_project.frontend.url
# }