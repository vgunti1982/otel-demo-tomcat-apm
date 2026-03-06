# OpenTelemetry Spring Boot Application on Tomcat with Jaeger and Grafana

This project demonstrates a complete observability stack with a Spring Boot application deployed on Apache Tomcat, instrumented with OpenTelemetry, and monitored through Jaeger and Grafana.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    Monitoring Stack                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────┐      ┌──────────────────┐               │
│  │  Spring Boot     │      │                  │               │
│  │  Application     │────→ │  OTEL Collector  │──┐            │
│  │  on Tomcat       │      │  (Port 4317)     │  │            │
│  │                  │      │                  │  │            │
│  │  - Service Name: │      └──────────────────┘  │            │
│  │    hello-world-  │                            │            │
│  │    spring-boot-  │      ┌──────────────────┐  │            │
│  │    sample-app    │      │                  │  │            │
│  │                  │      │  Prometheus      │──+──→ Metrics │
│  │  - Environment:  │      │  (Port 9090)     │  │            │
│  │    SANDBOX       │      │                  │  │            │
│  │                  │      └──────────────────┘  │            │
│  │  - Metrics:      │                            │            │
│  │    /actuator/    │      ┌──────────────────┐  │            │
│  │    prometheus    │      │                  │  └──→ Traces  │
│  │                  │      │  Jaeger UI       │               │
│  │  - Traces:       │      │  (Port 16686)    │               │
│  │    OTLP Protocol │      │                  │               │
│  │                  │      └──────────────────┘               │
│  └──────────────────┘                                         │
│         │                 ┌──────────────────┐               │
│         │                 │                  │               │
│         └────────────────→│  Grafana         │               │
│      HTTP Scraping        │  (Port 3000)     │               │
│      (Prometheus)         │  Admin: admin    │               │
│                           │  Pass: admin123  │               │
│                           │                  │               │
│                           └──────────────────┘               │
│                                                               │
└─────────────────────────────────────────────────────────────────┘
```

## Features

✅ **Spring Boot Application**
- RESTful API with multiple endpoints
- Actuator endpoints for health and metrics
- Custom business metrics (request counter)

✅ **OpenTelemetry Instrumentation**
- Automatic tracing via Java agent
- Custom metrics and span attributes
- Trace context propagation
- OTLP exporter configuration

✅ **Tomcat Deployment**
- WAR file packaging
- Container-based deployment with Docker
- Exposed metrics endpoint for Prometheus

✅ **Observability Stack**
- **Jaeger**: Distributed tracing (view traces at http://localhost:16686)
- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization dashboard (http://localhost:3000)
- **OTEL Collector**: Trace and metric aggregation

✅ **Configuration**
- Service name: `hello-world-spring-boot-sample-app`
- Deployment environment: `SANDBOX`
- Service version: `1.0.0`

## Prerequisites

- Docker and Docker Compose
- Java 17 (for building the application)
- Maven 3.6+
- Git

## Quick Start

### 1. Clone and Navigate to the Repository

```bash
cd /workspaces/otel-demo-tomcat-apm
```

### 2. Build and Deploy

```bash
chmod +x build-and-deploy.sh
./build-and-deploy.sh
```

This script will:
- Build the Spring Boot application as a WAR file
- Download the OpenTelemetry Java agent
- Build the custom Tomcat Docker image
- Start all services using docker-compose

### 3. Verify the Stack

Wait 30-60 seconds for all services to start, then test the application:

```bash
# Test the application
curl http://localhost:8080/hello-world-spring-boot-sample-app/

# Check health
curl http://localhost:8080/hello-world-spring-boot-sample-app/health

# View metrics
curl http://localhost:8080/hello-world-spring-boot-sample-app/actuator/prometheus
```

## Accessing the UIs

### Application
- **URL**: http://localhost:8080/hello-world-spring-boot-sample-app/
- **Endpoints**:
  - `/`: Home page
  - `/api/hello`: JSON hello endpoint
  - `/api/hello/{name}`: Personalized greeting
  - `/health`: Health check
  - `/info`: Service information

### Jaeger UI (Distributed Tracing)
- **URL**: http://localhost:16686
- View all traces from `hello-world-spring-boot-sample-app`
- See span relationships, latencies, and errors
- Components inspected: OTEL Collector, Tomcat, Spring Boot

### Grafana (Metrics Visualization)
- **URL**: http://localhost:3000
- **Credentials**: admin / admin123
- **Dashboards**: Spring Boot with OTEL - Hello World App
- **Available Metrics**:
  - Request rate (requests/sec)
  - Total requests count
  - JVM heap memory usage
  - Process CPU usage
  - And more!

### Prometheus (Metrics Storage)
- **URL**: http://localhost:9090
- Query metrics directly
- View targets and alerts
- Graph time series data

## Application Structure

```
otel-demo-tomcat-apm/
├── app/                              # Spring Boot Application
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/example/helloworld/
│   │   │   │   └── HelloWorldApplication.java
│   │   │   └── resources/
│   │   │       └── application.properties
│   │   └── test/
│   ├── pom.xml                       # Maven dependencies
│   └── target/
│       └── hello-world-spring-boot-sample-app-1.0.0.war
├── docker-compose.yml                # Orchestration
├── Dockerfile                        # Tomcat with OTEL agent
├── otel-collector-config.yml        # OTEL Collector configuration
├── prometheus.yml                    # Prometheus scrape config
├── grafana-provisioning/
│   ├── datasources/
│   │   └── datasources.yml
│   └── dashboards/
│       ├── dashboards.yml
│       └── spring-boot-dashboard.json
├── build-and-deploy.sh              # Build and deployment script
└── README.md
```

## Key Configuration Details

### OpenTelemetry Configuration (application.properties)

```properties
# Service name and environment
otel.service.name=hello-world-spring-boot-sample-app
otel.resource.attributes=deployment.environment=SANDBOX,service.name=hello-world-spring-boot-sample-app,service.version=1.0.0

# Exporters
otel.traces.exporter=otlp
otel.metrics.exporter=otlp
otel.logs.exporter=otlp

# OTEL Collector endpoint
otel.exporter.otlp.endpoint=http://otel-collector:4317

# Sampling
management.tracing.sampling.probability=1.0
```

### OTEL Collector Configuration (otel-collector-config.yml)

- **Receivers**: OTLP (gRPC and HTTP)
- **Processors**: Batch, Memory Limiter, Attributes
- **Exporters**: Jaeger, Prometheus
- **Attributes**: Automatically adds `deployment.environment=SANDBOX`

### Prometheus Configuration (prometheus.yml)

- Sources:
  - Application metrics via `/hello-world-spring-boot-sample-app/actuator/prometheus`
  - OTEL Collector metrics via `:8889/metrics`
- Scrape interval: 10 seconds for Tomcat app
- Global labels: `environment=SANDBOX`, `service=hello-world-spring-boot-sample-app`

### Grafana Dashboards

Pre-configured dashboard showing:
- Request rate (1-minute rate)
- Total request count
- JVM heap memory usage
- Process CPU usage

## Testing and Load Generation

To generate some traffic for observability:

```bash
# Generate requests in a loop
for i in {1..100}; do
  curl http://localhost:8080/hello-world-spring-boot-sample-app/ &
  curl http://localhost:8080/hello-world-spring-boot-sample-app/api/hello/World &
  sleep 1
done

# Or use Apache Bench if installed
ab -n 100 -c 10 http://localhost:8080/hello-world-spring-boot-sample-app/
```

## Troubleshooting

### Containers not starting

```bash
# Check container logs
docker-compose logs -f

# Check specific service
docker-compose logs -f tomcat
docker-compose logs -f jaeger
docker-compose logs -f grafana
```

### Metrics not appearing in Grafana

1. Wait 2-3 minutes for data collection
2. Verify Prometheus target: http://localhost:9090/targets
3. Generate some traffic to the application
4. Check datasource connection in Grafana

### Traces not appearing in Jaeger

1. Ensure OTEL Collector is running: `docker-compose logs otel-collector`
2. Check application logs: `docker-compose logs tomcat`
3. Verify endpoint configuration in application.properties

### What if ports are already in use?

Edit `docker-compose.yml` to use different ports:

```yaml
services:
  tomcat:
    ports:
      - "8081:8080"  # Changed from 8080
  grafana:
    ports:
      - "3001:3000"  # Changed from 3000
```

Then update your URLs accordingly.

## Stopping the Stack

```bash
# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# View logs while stopping
docker-compose logs -f
```

## Cleaning Up

```bash
# Remove containers, networks
docker-compose down

# Remove built images
docker rmi tomcat-otel-app:latest

# Clean Maven build
cd app && mvn clean && cd ..

# Remove downloaded agent
rm -rf agent/ opentelemetry-javaagent.jar
```

## Advanced Topics

### Custom Metrics

Add custom metrics in the application:

```java
@Component
public class CustomMetrics {
    private final MeterRegistry meterRegistry;
    
    @PostConstruct
    public void setup() {
        Gauge.builder("custom.metric", () -> 42)
            .description("Custom metric example")
            .register(meterRegistry);
    }
}
```

### Custom Spans

```java
@Autowired
private Tracer tracer;

public void methodWithSpan() {
    try (Scope scope = tracer.spanBuilder("custom-operation").startAndMakeActive()) {
        // Your code here
    }
}
```

### OTEL Java Agent Configuration

The Java agent is automatically injected via `CATALINA_OPTS`:

```bash
CATALINA_OPTS="-javaagent:/usr/local/tomcat/opentelemetry-javaagent.jar \
    -Dotel.javaagent.debug=false \
    -Dotel.service.name=hello-world-spring-boot-sample-app"
```

Common properties:
- `otel.javaagent.debug=true`: Enable debug mode
- `otel.instrumentation.*.enabled=false`: Disable specific instrumentations
- `otel.traces.sampler=parentbased_always_on`: Sampling strategy

## Environment Variables

Key environment variables used in docker-compose.yml:

```bash
OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317
OTEL_SERVICE_NAME=hello-world-spring-boot-sample-app
OTEL_RESOURCE_ATTRIBUTES=deployment.environment=SANDBOX,service.name=hello-world-spring-boot-sample-app,service.version=1.0.0
OTEL_TRACES_EXPORTER=otlp
OTEL_METRICS_EXPORTER=otlp
```

## Performance Considerations

- **Sampling**: Currently set to 100% (`management.tracing.sampling.probability=1.0`)
  - For production, reduce to 10% or use adaptive sampling
- **Batch Size**: OTEL Collector set to send 1024 traces per batch
- **Memory**: Tomcat configured with `-Xmx512m -Xms256m`

## References

- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [OpenTelemetry Java](https://opentelemetry.io/docs/instrumentation/java/)
- [Jaeger Documentation](https://www.jaegertracing.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/grafana/latest/)
- [Prometheus Documentation](https://prometheus.io/docs/)

## License

This project is provided as-is for demonstration purposes.

## Support

For issues or questions:
1. Check the logs: `docker-compose logs`
2. Verify all services are healthy: `docker-compose ps`
3. Check endpoints are responding
4. Review OpenTelemetry documentation

---

**Project**: OpenTelemetry Demo with Spring Boot on Tomcat  
**Service Name**: hello-world-spring-boot-sample-app  
**Environment**: SANDBOX  
**Version**: 1.0.0
