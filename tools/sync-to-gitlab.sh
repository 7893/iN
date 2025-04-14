#!/bin/bash

# ~/iN/tools/sync-to-gitlab.sh
# This script syncs relevant environment variables to GitLab CI/CD environment variables

# Ensure .env.secrets exists
if [[ ! -f ~/iN/.env.secrets ]]; then
    echo ".env.secrets file not found!"
    exit 1
fi

# Load the secrets from .env.secrets
source ~/iN/.env.secrets

# GitLab project ID and PAT (ensure the environment variable is set)
if [[ -z "$GITLAB_PROJECT_ID" || -z "$GITLAB_PAT" ]]; then
    echo "GITLAB_PROJECT_ID or GITLAB_PAT is not set!"
    exit 1
fi

# Only include the relevant GitLab variables for CI/CD
gitlab_secrets=(
  "GITLAB_PROJECT_ID"
  "GITLAB_PROJECT_NAME"
  "RUNTIME_UNSPLASH_ACCESS_KEY"
  "RUNTIME_R2_S3_ACCESS_KEY_ID"
  "RUNTIME_R2_S3_SECRET_ACCESS_KEY"
  "RUNTIME_HMAC_SECRET"
  "RUNTIME_EXTERNAL_AI_API_KEY"
  "RUNTIME_R2_S3_ENDPOINT_DEFAULT"
  "RUNTIME_R2_S3_ENDPOINT_EU"
  "AXIOM_API_TOKEN"
)

echo "Syncing environment variables to GitLab..."

for secret in "${gitlab_secrets[@]}"; do
    value="${!secret}"
    if [[ -z "$value" ]]; then
        echo "Skipping empty secret: $secret"
        continue
    fi

    # Upload each secret to GitLab CI/CD environment variables
    echo "Syncing $secret to GitLab..."
    curl --request POST --header "PRIVATE-TOKEN: $GITLAB_PAT" \
        --data "key=$secret" \
        --data "value=$value" \
        --data "variable_type=env_var" \
        --data "masked=true" \
        --data "protected=false" \
        --data "environment_scope=*" \
        "https://gitlab.com/api/v4/projects/$GITLAB_PROJECT_ID/variables"

    if [[ $? -eq 0 ]]; then
        echo "$secret synced successfully to GitLab."
    else
        echo "Failed to sync $secret to GitLab."
    fi
done

echo "GitLab variable sync complete!"
