#!/bin/bash
# Script to apply platform addons with environment variable substitution

set -e

# Check required environment variables
if [ -z "$AWS_ACCOUNT_ID" ]; then
  echo "Error: AWS_ACCOUNT_ID environment variable is not set"
  exit 1
fi

if [ -z "$AWS_REGION" ]; then
  echo "Error: AWS_REGION environment variable is not set"
  exit 1
fi

echo "Applying platform addons with:"
echo "  AWS_ACCOUNT_ID: $AWS_ACCOUNT_ID"
echo "  AWS_REGION: $AWS_REGION"

# Apply addons with environment variable substitution
for file in platform/addons/*.yaml; do
  echo "Applying $file..."
  envsubst < "$file" | kubectl apply -f -
done

echo "Platform addons applied successfully"
