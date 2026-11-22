#!/usr/bin/env bash
# Part 2: installs Prometheus + Grafana with Argo CD, then the DevOps Coffee monitoring (scraping, alerts, dashboard).
set -euo pipefail
cd "$(dirname "$0")/.."
./scripts/check-context.sh

echo "📈 Asking Argo CD to install Prometheus + Grafana (kube-prometheus-stack)..."
kubectl apply -f argocd/monitoring-stack.yaml

echo "⏳ Waiting for Grafana and Prometheus (first time: 3–6 minutes)..."
until kubectl get deployment monitoring-grafana -n monitoring >/dev/null 2>&1; do sleep 5; done
kubectl rollout status deployment/monitoring-grafana -n monitoring --timeout=600s
until kubectl get statefulset prometheus-monitoring-prometheus -n monitoring >/dev/null 2>&1; do sleep 5; done
kubectl rollout status statefulset/prometheus-monitoring-prometheus -n monitoring --timeout=600s

echo "🔎 Adding DevOps Coffee monitoring (ServiceMonitor, alerts, dashboard)..."
kubectl apply -f argocd/monitoring.yaml

echo
echo "✅ Monitoring is installed."
echo "   Grafana:     ./scripts/grafana-ui.sh"
echo "   Prometheus:  ./scripts/prometheus-ui.sh"
