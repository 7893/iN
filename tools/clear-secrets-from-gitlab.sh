#!/bin/bash

# ~/iN/tools/clear-secrets-from-gitlab.sh
# This script clears GitLab CI/CD environment variables

# Ensure .env.secrets exists
if [[ ! -f ~/iN/.env.secrets ]]; then
    echo ".env.secrets file not found!"
    exit 1
fi

# Load the secrets from .env.secrets
source ~/iN/.env.secrets

# Define the GitLab secrets to clear
gitlab_secrets=(
  "CLOUDFLARE_ACCOUNT_ID"
  "TF_VAR_cloudflare_account_id"
  "CLOUDFLARE_API_TOKEN"
  "CLOUDFLARE_R2_API_TOKEN"
  "TF_VAR_cloudflare_workers_dev_account_name"
  "GITLAB_PAT"
  "GITLAB_PROJECT_ID"
  "GITLAB_PROJECT_NAME"
  "GITLAB_OWNER"
  "RUNTIME_UNSPLASH_ACCESS_KEY"
  "RUNTIME_R2_S3_ACCESS_KEY_ID"
  "RUNTIME_R2_S3_SECRET_ACCESS_KEY"
  "RUNTIME_HMAC_SECRET"
  "RUNTIME_EXTERNAL_AI_API_KEY"
  "RUNTIME_R2_S3_ENDPOINT_DEFAULT"
  "RUNTIME_R2_S3_ENDPOINT_EU"
  "AXIOM_API_TOKEN"
)

echo "Clearing GitLab CI/CD environment variables..."

# Loop through each variable and delete it from GitLab
for secret in "${gitlab_secrets[@]}"; do
    echo "Clearing $secret from GitLab..."
    
    # Delete the secret from GitLab CI/CD environment variables
    curl --request DELETE \
        --header "PRIVATE-TOKEN: $GITLAB_PAT" \
        "https://gitlab.com/api/v4/projects/$GITLAB_PROJECT_ID/variables/$secret"
    
    if [[ $? -eq 0 ]]; then
        echo "$secret cleared successfully from GitLab."
    else
        echo "Failed to clear $secret from GitLab."
    fi
done

echo "GitLab variable clearing complete!"

