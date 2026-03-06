# Essential Commands Reference

## View System Status

```bash
# Check all containers
docker compose ps

# View logs (all services)
docker compose logs -f

# View logs (specific service)
docker compose logs -f tomcat
docker compose logs -f jaeger
docker compose logs -f grafana
docker compose logs -f prometheus
docker compose logs -f otel-collector

# Check service health
curl http://localhost:8080/hello-world-spring-boot-sample-app/health | jq
```

## Test the Application

```bash
# Home page
curl http://localhost:8080/hello-world-spring-boot-sample-app/

# API endpoint (JSON)
curl http://localhost:8080/hello-world-spring-boot-sample-app/api/hello | jq

# API with parameter
curl http://localhost:8080/hello-world-spring-boot-sample-app/api/hello/World

# Service info
curl http://localhost:8080/hello-world-spring-boot-sample-app/info | jq

# Metrics (Prometheus format)
curl http://localhost:8080/hello-world-spring-boot-sample-app/actuator/prometheus
```

## Generate Test Traffic

```bash
# Simple: 20 requests
for i in {1..20}; do
  curl -s http://localhost:8080/hello-world-spring-boot-sample-app/ > /dev/null
  sleep 0.5
done

# Concurrent: 100 requests with 10 parallel connections
ab -n 100 -c 10 http://localhost:8080/hello-world-spring-boot-sample-app/

# Continuous load (press Ctrl+C to stop)
while true; do
  curl -s http://localhost:8080/hello-world-spring-boot-sample-app/ > /dev/null
  sleep 1
done

# Load with delay variation
for i in {1..50}; do
  curl -s http://localhost:8080/hello-world-spring-boot-sample-app/api/hello/User$i > /dev/null &
  sleep $(echo "scale=2; $RANDOM/32767" | bc)
done
```

## Metrics Queries

### Prometheus Web UI
Visit: http://localhost:9090

```promql
# Request rate (requests per second)
rate(hello_world_requests_total[1m])

# Total requests
hello_world_requests_total

# HTTP request duration (95th percentile)
histogram_quantile(0.95, rate(http_server_requests_seconds_bucket[5m]))

# JVM memory usage
jvm_memory_usage_bytes{type="heap"}

# CPU usage
process_cpu_usage

# All metrics from the app
{job="hello-world-app"}
```

## Jaeger Operations

```bash
# List all services
curl http://localhost:16686/api/services | jq

# Get traces for a service
curl http://localhost:16686/api/traces?service=hello-world-spring-boot-sample-app | jq

# Search for slow requests (>100ms)
# Use the Jaeger UI: http://localhost:16686
# - Select service: hello-world-spring-boot-sample-app
# - Click "Find Traces"
```

## Grafana Operations

```bash
# Get API token (for programmatic access)
curl -s http://localhost:3000/api/auth/keys \
  -H "Authorization: Bearer $(curl -s -X POST http://localhost:3000/api/auth/login \
    -H 'Content-Type: application/json' \
    -d '{\"user\":\"admin\",\"password\":\"admin123\"}' | jq -r '.token')"

# List dashboards
curl http://localhost:3000/api/search | jq

# Get specific dashboard
curl http://localhost:3000/api/dashboards/uid/spring-boot-otel | jq
```

## Docker Compose Management

```bash
# Start services (if stopped)
docker compose up -d

# Restart all services
docker compose restart

# Restart specific service
docker compose restart tomcat

# Stop all services (keep volumes)
docker compose stop

# Stop all services (remove volumes)
docker compose down -v

# Pause/Unpause services
docker compose pause
docker compose unpause

# Scale services (if configured)
docker compose up -d --scale tomcat=2
```

## Rebuild & Redeploy

```bash
# Rebuild Spring Boot application only
cd app && mvn clean package -DskipTests && cd ..

# Rebuild Docker image (Tomcat with OTEL)
docker build -t tomcat-otel-app:latest .

# Full rebuild from scratch
docker compose down -v
rm -rf app/target/
mvn clean package -DskipTests
docker compose up -d
```

## Debugging

```bash
# Check if ports are in use
lsof -i :8080
lsof -i :3000
lsof -i :9090
lsof -i :16686

# View container resource usage
docker stats

# Inspect container
docker inspect otel-jaeger | jq

# Execute command in running container
docker compose exec tomcat bash
docker compose exec grafana sh

# View environment variables in container
docker compose exec tomcat env | grep OTEL

# Check container network
docker network inspect otel-demo-tomcat-apm_otel-network | jq
```

## Log File Locations

```bash
# All logs
docker compose logs > all-logs.txt

# Specific service logs
docker compose logs tomcat > tomcat-logs.txt
docker compose logs grafana > grafana-logs.txt

# Since timestamp (last 1 hour)
docker compose logs --since 1h -f
```

## Performance Monitoring

```bash
# CPU and Memory usage
watch docker stats

# Network traffic
docker stats tomcat --no-stream

# Disk usage (volumes)
docker volume ls
docker volume inspect otel-demo-tomcat-apm_prometheus_data | jq '.[0].Mountpoint'
```

## Cleanup

```bash
# Remove all containers and volumes
docker compose down -v

# Remove images
docker rmi tomcat-otel-app:latest

# Clean Maven
cd app && mvn clean && cd ..

# Remove downloaded agent
rm -rf agent/

# Full cleanup (keep code, remove runtime artifacts)
docker compose down -v
rm -rf app/target/
rm -rf agent/
rm opentelemetry-javaagent.jar
```

## Useful Tips

### Forward Ports (if running in WSL/VM)
```bash
# Enable port forwarding for remote access
ssh -N -f -L 8080:localhost:8080 -L 3000:localhost:3000 -L 9090:localhost:9090 -L 16686:localhost:16686 user@host
```

### Monitor Live
```bash
# Terminal 1: Watch logs
docker compose logs -f tomcat

# Terminal 2: Generate load
while true; do curl -s http://localhost:8080/hello-world-spring-boot-sample-app/ > /dev/null; sleep 1; done

# Terminal 3: Query metrics
watch "curl -s http://localhost:9090/api/v1/query?query=rate | jq '.data.result[0]'"
```

### Export Data
```bash
# Export Prometheus data
curl http://localhost:9090/api/v1/query?query=up > prometheus-export.json

# Export Grafana dashboard
curl http://localhost:3000/api/dashboards/uid/spring-boot-otel > dashboard.json

# Export Jaeger traces (UI method preferred)
# Visit http://localhost:16686 > Service > Download
```

## Troubleshooting Commands

```bash
# Test connectivity to endpoints
curl -v http://localhost:8080/hello-world-spring-boot-sample-app/
curl -v http://localhost:16686/api/services
curl -v http://localhost:3000/api/health
curl -v http://localhost:9090/api/v1/query

# Check OTEL Agent logs
docker compose logs tomcat | grep -i "otel\|instrumentation\|exporter"

# Verify metrics are being scraped
curl http://localhost:9090/api/v1/targets | jq '.data.activeTargets'

# Check datasource connectivity in Grafana
curl http://localhost:3000/api/datasources | jq

# List all running processes in Tomcat
docker compose exec tomcat ps aux | grep java
```

---

## Quick Reference URLs

| Service | URL | Purpose |
|---------|-----|---------|
| Application | http://localhost:8080/hello-world-spring-boot-sample-app/ | Main app |
| Prometheus | http://localhost:9090 | Metrics query & storage |
| Grafana | http://localhost:3000 | Metrics dashboards |
| Jaeger | http://localhost:16686 | Distributed tracing |
| Metrics Endpoint | http://localhost:8080/hello-world-spring-boot-sample-app/actuator/prometheus | Prometheus metrics |
| Health Check | http://localhost:8080/hello-world-spring-boot-sample-app/health | App health |

---

For more information, see [DEPLOYMENT_SUMMARY.md](DEPLOYMENT_SUMMARY.md) or [README.md](README.md)
