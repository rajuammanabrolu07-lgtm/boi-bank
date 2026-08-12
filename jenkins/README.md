# Jenkins pipeline (Phase 5-6)

Jenkinsfile (declarative) stages:
  Checkout -> Build+Test (mvn) -> SonarQube scan + Quality Gate
  -> Docker build -> Trivy scan -> Push to ECR (tag = git SHA)
  -> Deploy DEV (auto) -> Smoke test
  -> Deploy STAGING (auto) -> Smoke test
  -> [MANUAL APPROVAL] -> Deploy PROD

Jenkins + SonarQube run on their own EC2 build server.
Coming in Phase 5.
