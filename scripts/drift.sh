#!/usr/bin/env bash
# Makes a manual change on the cluster, the kind of change GitOps does NOT allow.
# Argo CD's self-heal puts it back to what Git says within seconds.
set -euo pipefail
"$(dirname "$0")/check-context.sh"
echo "😈 Someone scales the web app to 0 pods by hand (not through Git)..."
kubectl scale deployment web -n devops-coffee --replicas=0
echo
echo "👀 Watch Argo CD put it back to 2 replicas (what Git says):"
kubectl get deployment web -n devops-coffee -w
