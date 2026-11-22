#!/usr/bin/env bash
# Removes the app, monitoring (Part 2) and Argo CD from your cluster.
"$(dirname "$0")/check-context.sh" || exit 1
kubectl delete -f "$(dirname "$0")/../argocd/monitoring.yaml" --ignore-not-found
kubectl delete -f "$(dirname "$0")/../argocd/monitoring-stack.yaml" --ignore-not-found
kubectl delete namespace monitoring --ignore-not-found
kubectl delete -f "$(dirname "$0")/../argocd/application.yaml" --ignore-not-found
kubectl delete namespace devops-coffee --ignore-not-found
read -r -p "Also uninstall Argo CD? (y/N) " a
if [ "$a" = "y" ]; then kubectl delete namespace argocd --ignore-not-found; fi
echo "🧹 Done."
