#!/usr/bin/env bash
# Opens DevOps Coffee at http://localhost:8090 (leave this running in its own tab).
"$(dirname "$0")/check-context.sh" || exit 1
echo "☕ DevOps Coffee → http://localhost:8090   (Ctrl + C to stop)"
while true; do
  kubectl port-forward svc/web -n devops-coffee 8090:80 >/dev/null 2>&1
  sleep 1
done
