# ~/iN/infra/providers.tf
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0" # 您可以根据需要调整版本约束
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}