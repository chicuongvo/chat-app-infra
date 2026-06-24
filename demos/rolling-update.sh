#!/bin/bash
set -euo pipefail

NAMESPACE=chatapp
SERVICE=${1:-chat-service}
NEW_TAG=${2:-latest}
REGISTRY=${3:-ghcr.io/YOUR_ORG}

echo "=== Rolling Update Demo: $SERVICE → $NEW_TAG ==="
echo ""
echo "Current deployment:"
kubectl get deployment $SERVICE -n $NAMESPACE

echo ""
echo "Triggering rolling update..."
kubectl set image deployment/$SERVICE \
  $SERVICE=$REGISTRY/chatapp-$SERVICE:$NEW_TAG \
  -n $NAMESPACE

echo ""
echo "Watching rollout progress..."
kubectl rollout status deployment/$SERVICE -n $NAMESPACE

echo ""
echo "Rollout history:"
kubectl rollout history deployment/$SERVICE -n $NAMESPACE

echo ""
echo "Current pods after update:"
kubectl get pods -n $NAMESPACE -l app=$SERVICE -o wide
