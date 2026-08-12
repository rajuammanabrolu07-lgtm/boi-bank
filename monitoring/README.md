# Monitoring (Phase 7)

- Prometheus: scrapes /actuator/prometheus on every pod (ServiceMonitor)
- Grafana: dashboards for JVM, HTTP latency, error rate per service
- Alertmanager: alert on pod down / high error rate / high latency
Installed via kube-prometheus-stack Helm chart.
Coming in Phase 7.
