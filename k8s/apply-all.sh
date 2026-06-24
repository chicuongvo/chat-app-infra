#!/usr/bin/env bash
# Apply all Kubernetes manifests in correct order
set -euo pipefail

echo "==> Creating namespace..."
kubectl apply -f namespace.yaml

echo "==> Deploying secrets..."
kubectl apply -f infra/secrets.yaml

echo "==> Deploying infrastructure..."
kubectl apply -f infra/rabbitmq.yaml
kubectl apply -f infra/redis.yaml
kubectl apply -f infra/mongodb.yaml
kubectl apply -f infra/postgresql.yaml

echo "==> Waiting for infra to be ready..."
kubectl wait --for=condition=ready pod -l app=rabbitmq -n chatapp --timeout=120s
kubectl wait --for=condition=ready pod -l app=redis     -n chatapp --timeout=60s
kubectl wait --for=condition=ready pod -l app=mongodb   -n chatapp --timeout=90s

echo "==> Deploying services..."
kubectl apply -f services/auth-service.yaml
kubectl apply -f services/user-service.yaml
kubectl apply -f services/chat-service.yaml
kubectl apply -f services/multimedia-service.yaml
kubectl apply -f services/notification-service.yaml
kubectl apply -f services/realtime-service.yaml
kubectl apply -f services/gateway.yaml

echo "==> All resources applied."
kubectl get all -n chatapp
