# Chat Application — Infrastructure

Shared infrastructure for the Chat Application microservices project (SE361).

## Repository Structure

```
├── k8s/                    Kubernetes manifests
│   ├── namespace.yaml
│   ├── infra/              RabbitMQ, Redis, MongoDB, PostgreSQL, MinIO, Secrets
│   └── services/           Deployments + Services for all 7 microservices
├── helm/
│   └── chat-app/           Umbrella Helm chart with 7 subcharts
│       ├── values.yaml
│       ├── values-staging.yaml
│       ├── values-production.yaml
│       └── charts/         auth, user, chat, multimedia, notification, realtime, gateway
├── observability/
│   ├── docker-compose.observability.yml
│   ├── prometheus/         Scrape configs (port 9464 on all services)
│   ├── grafana/            Dashboards + datasources
│   └── elk/                Logstash pipeline
├── load-tests/             k6 load test scenarios (100/500/1000 VUs)
├── demos/                  Kubernetes demo scripts for presentation
└── proto/                  Shared gRPC proto definitions
```

## Service Repositories

| Service | Repository |
|---|---|
| API Gateway | github.com/chicuongvo/chat-app-gateway |
| Auth Service | github.com/nguyenxduc/chat-app-auth-service |
| User Service | github.com/nguyenxduc/chat-app-user-service |
| Chat Service | github.com/tungduong150105/chatapp-conversation |
| Multimedia Service | github.com/nguyenxduc/chat-app-multimedia-service |
| Notification Service | github.com/tungduong150105/chatapp-notification |
| Realtime Service | github.com/chicuongvo/realtime-service |

## Deploying with Kubernetes

```bash
# Apply namespace and infra first
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/infra/

# Apply all services
kubectl apply -f k8s/services/

# Or use the helper script
bash k8s/apply-all.sh
```

## Deploying with Helm

```bash
helm install chat-app ./helm/chat-app \
  --namespace chatapp \
  --create-namespace \
  -f helm/chat-app/values.yaml
```

## Observability Stack

```bash
docker compose -f observability/docker-compose.observability.yml up -d
```

- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000 (admin/admin)
- Jaeger: http://localhost:16686
- Kibana: http://localhost:5601

Services expose metrics on port 9464 (`/metrics`).

## Load Testing

```bash
k6 run load-tests/scenarios/100-users.js
k6 run load-tests/scenarios/500-users.js
k6 run load-tests/scenarios/1000-users.js
```

## Kubernetes Demo Scripts

```bash
bash demos/self-healing.sh
bash demos/rolling-update.sh
bash demos/hpa-demo.sh
bash demos/service-discovery.sh
```
