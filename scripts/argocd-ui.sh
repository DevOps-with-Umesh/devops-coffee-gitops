#!/usr/bin/env bash
# Opens the Argo CD web UI at https://localhost:8443 (leave this running in its own tab).
"$(dirname "$0")/check-context.sh" || exit 1
PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' 2>/dev/null | base64 --decode)
echo "🐙 Argo CD UI → https://localhost:8443"
echo "   Username: admin"
echo "   Password: ${PASS:-<not found: was the initial secret deleted?>}"
echo "   (Your browser warns about the certificate: click Advanced → Proceed. It's your own local cluster.)"
echo "   Ctrl + C to stop."
while true; do
  kubectl port-forward svc/argocd-server -n argocd 8443:443 >/dev/null 2>&1
  sleep 2
done
