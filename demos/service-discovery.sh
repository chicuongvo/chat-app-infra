#!/bin/bash
set -euo pipefail

NAMESPACE=chatapp

echo "=== Service Discovery Demo ==="
echo ""
echo "All services in namespace $NAMESPACE:"
kubectl get svc -n $NAMESPACE

echo ""
echo "--- DNS resolution inside cluster ---"
echo "Launching a debug pod..."
kubectl run dns-test --image=busybox:1.36 --restart=Never -n $NAMESPACE -- sleep 30

sleep 3

echo ""
echo "Resolving auth-service:"
kubectl exec dns-test -n $NAMESPACE -- nslookup auth-service.$NAMESPACE.svc.cluster.local

echo ""
echo "Resolving user-service:"
kubectl exec dns-test -n $NAMESPACE -- nslookup user-service.$NAMESPACE.svc.cluster.local

echo ""
echo "Resolving chat-service:"
kubectl exec dns-test -n $NAMESPACE -- nslookup chat-service.$NAMESPACE.svc.cluster.local

echo ""
echo "Resolving gateway:"
kubectl exec dns-test -n $NAMESPACE -- nslookup gateway.$NAMESPACE.svc.cluster.local

echo ""
echo "Cleaning up debug pod..."
kubectl delete pod dns-test -n $NAMESPACE

echo ""
echo "Endpoints registered:"
kubectl get endpoints -n $NAMESPACE
