# BOI Bank — Enterprise Microservices DevOps Project

A hands-on, end-to-end enterprise DevOps pipeline built around a small banking
microservices app. The app is deliberately simple so the **pipeline** is the star:
CI/CD, security scanning, multi-environment promotion with approvals, IaC, and
full observability.

## Services

| Service                    | Port | Purpose                                  | DB       |
|----------------------------|------|------------------------------------------|----------|
| boi-api-gateway            | 8080 | Single entry point, routes to services   | -        |
| boi-auth-service           | 8081 | Login + JWT issuance/validation          | in-memory|
| boi-account-service        | 8082 | Accounts & balances                      | Postgres |
| boi-transaction-service    | 8083 | Transfers / ledger                       | Postgres |

Each service exposes:
- `/actuator/health/liveness` and `/actuator/health/readiness`  (k8s probes)
- `/actuator/prometheus`  (metrics for Prometheus/Grafana)

## Run the whole stack locally (no laptop installs needed if using Codespaces)

```bash
docker compose up --build
```

Then:

```bash
# get a token
curl -X POST http://localhost:8080/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"username":"raju","password":"password123"}'

# create an account
curl -X POST http://localhost:8080/accounts \
  -H 'Content-Type: application/json' \
  -d '{"accountNumber":"BOI001","holderName":"Raju","balance":5000}'

# list accounts
curl http://localhost:8080/accounts

# record a transfer
curl -X POST http://localhost:8080/transactions/transfer \
  -H 'Content-Type: application/json' \
  -d '{"fromAccountId":1,"toAccountId":2,"amount":250}'
```

## Build phases

| Phase | Layer                    | Status        |
|-------|--------------------------|---------------|
| 1     | Microservices (this)     | ✅ done       |
| 2     | Docker + compose (this)  | ✅ done       |
| 3     | Terraform (VPC/EKS/ECR)  | ⏳ next        |
| 4     | Kubernetes manifests     | ⏳            |
| 5     | Jenkins CI               | ⏳            |
| 6     | CD + approvals           | ⏳            |
| 7     | Prometheus + Grafana     | ⏳            |
| 8     | Security hardening       | ⏳            |

## Security notes (baked in from day 1)
- No hardcoded secrets — DB creds & JWT secret come from env / secret store.
- Containers run as non-root, JRE-only runtime image.
- Immutable image tags (git SHA), never `:latest`.
- Full folder layout for terraform/k8s/jenkins/monitoring is scaffolded.
