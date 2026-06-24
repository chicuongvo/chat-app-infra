#!/bin/bash
set -euo pipefail

NAMESPACE=chatapp
SERVICE=${1:-chat-service}

echo "=== Self-Healing Demo: $SERVICE ==="
echo ""
echo "Current pods:"
kubectl get pods -n $NAMESPACE -l app=$SERVICE

POD=$(kubectl get pod -n $NAMESPACE -l app=$SERVICE -o jsonpath='{.items[0].metadata.name}')
echo ""
echo "Deleting pod: $POD"
kubectl delete pod $POD -n $NAMESPACE

echo ""
echo "Watching Kubernetes restart the pod automatically..."
kubectl get pods -n $NAMESPACE -l app=$SERVICE -w &
WATCH_PID=$!

sleep 30
kill $WATCH_PID 2>/dev/null || true

echo ""
echo "Final pod state:"
kubectl get pods -n $NAMESPACE -l app=$SERVICE
