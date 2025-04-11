# 例如: ~/iN/infra/d1/providers.tf (其他子目录类似)
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}