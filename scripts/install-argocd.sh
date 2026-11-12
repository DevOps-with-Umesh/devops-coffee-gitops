#!/usr/bin/env bash
# Installs Argo CD into the "argocd" namespace (official install manifest).
set -euo pipefail
"$(dirname "$0")/check-context.sh"

echo "📦 Installing Argo CD..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd --server-side --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "⏳ Waiting for Argo CD to start (1–3 minutes)..."
kubectl wait --for=condition=available deployment --all -n argocd --timeout=300s
kubectl rollout status statefulset/argocd-application-controller -n argocd --timeout=300s

# Demo setting: check Git every 30 seconds instead of the default 3 minutes.
kubectl -n argocd patch configmap argocd-cm --type merge -p '{"data":{"timeout.reconciliation":"30s"}}'
kubectl -n argocd rollout restart deployment argocd-repo-server
kubectl -n argocd rollout restart statefulset argocd-application-controller
kubectl -n argocd rollout status statefulset/argocd-application-controller --timeout=300s

echo
echo "✅ Argo CD is installed."
echo "   Open the UI with:  ./scripts/argocd-ui.sh"
