#!/usr/bin/env bash
# Tells Argo CD to deploy this repo's k8s/ folder (the Application resource).
set -euo pipefail
"$(dirname "$0")/check-context.sh"
kubectl apply -f "$(dirname "$0")/../argocd/application.yaml"
echo "✅ Argo CD Application 'devops-coffee' created. Watch it sync in the UI."
