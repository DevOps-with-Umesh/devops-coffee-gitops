#!/usr/bin/env bash
# Opens Grafana at http://localhost:3000 (leave this running in its own tab).
"$(dirname "$0")/check-context.sh" || exit 1
echo "📊 Grafana → http://localhost:3000   user: admin   password: devops-coffee"
echo "   Dashboards → ☕ DevOps Coffee   (Ctrl + C to stop)"
while true; do
  kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80 >/dev/null 2>&1
  sleep 1
done
