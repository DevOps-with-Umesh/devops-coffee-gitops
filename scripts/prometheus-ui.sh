#!/usr/bin/env bash
# Opens Prometheus at http://localhost:9090 (leave this running in its own tab).
"$(dirname "$0")/check-context.sh" || exit 1
echo "🔥 Prometheus → http://localhost:9090   (Status → Targets, Alerts)   Ctrl + C to stop"
while true; do
  kubectl port-forward svc/monitoring-prometheus -n monitoring 9090:9090 >/dev/null 2>&1
  sleep 1
done
