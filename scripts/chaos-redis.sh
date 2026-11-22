#!/usr/bin/env bash
# Part 2 demo: break Redis on purpose and watch the error-rate alert fire.
#   ./scripts/chaos-redis.sh          → Redis goes down (orders fail with 503)
#   ./scripts/chaos-redis.sh restore  → Argo CD brings Redis back
# Argo CD's self-heal would undo the break within seconds, so we pause it during the demo.
set -euo pipefail
"$(dirname "$0")/check-context.sh"
heal() {
  kubectl patch application devops-coffee -n argocd --type merge \
    -p "{\"spec\":{\"syncPolicy\":{\"automated\":{\"prune\":true,\"selfHeal\":$1}}}}" >/dev/null
}
if [ "${1:-}" = "restore" ]; then
  heal true
  echo "🩹 Self-heal back on. Argo CD puts Redis back to 1 replica (what Git says)..."
  kubectl get deployment redis -n devops-coffee -w
else
  heal false
  echo "😈 Self-heal paused. Stopping Redis..."
  kubectl scale deployment redis -n devops-coffee --replicas=0
  echo "💥 Orders now fail with 503. Keep ./scripts/customers.sh running and watch:"
  echo "   Grafana → error rate goes red · Prometheus → Alerts → CoffeeHighErrorRate fires in ~2 minutes"
  echo "   Fix it with: ./scripts/chaos-redis.sh restore"
fi
