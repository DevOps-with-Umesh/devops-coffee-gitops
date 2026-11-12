#!/usr/bin/env bash
# Safety check used by the other scripts: only run against the local Docker Desktop cluster.
if [ "$(kubectl config current-context 2>/dev/null)" != "docker-desktop" ]; then
  echo "❌ kubectl is not pointing at docker-desktop. Run: kubectl config use-context docker-desktop"
  exit 1
fi
