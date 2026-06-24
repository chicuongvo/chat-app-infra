#!/bin/bash
set -euo pipefail

NAMESPACE=chatapp
SERVICE=${1:-chat-service}

echo "=== HPA Auto-Scaling Demo: $SERVICE ==="
echo ""
echo "Current HPA:"
kubectl get hpa $SERVICE -n $NAMESPACE

echo ""
echo "Current pods (before load):"
kubectl get pods -n $NAMESPACE -l app=$SERVICE

echo ""
echo "Starting load with k6 (100 VUs for 3 minutes)..."
echo "Run this in another terminal:"
echo "  k6 run --env BASE_URL=http://\$(kubectl get svc gateway -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}') load-tests/scenarios/100-users.js"
echo ""
echo "Watching HPA scale pods..."
kubectl get hpa $SERVICE -n $NAMESPACE -w &
HPA_WATCH=$!

kubectl get pods -n $NAMESPACE -l app=$SERVICE -w &
POD_WATCH=$!

echo "Press Ctrl+C to stop watching..."
wait $HPA_WATCH
kill $POD_WATCH 2>/dev/null || true
