#!/bin/bash

# OpenTelemetry Demo with Spring Boot on Tomcat - Build and Deploy Script

set -e

echo "=================================="
echo "Building Spring Boot Application"
echo "=================================="

# Navigate to app directory
cd app

# Build the WAR file with Maven
echo "Building WAR package..."
mvn clean package -DskipTests

echo ""
echo "=================================="
echo "WAR file created successfully!"
echo "=================================="

# Return to root directory
cd ..

echo ""
echo "=================================="
echo "Downloading OpenTelemetry Java Agent"
echo "=================================="

# Download OTEL Java agent for local use (if not already present)
if [ ! -f "opentelemetry-javaagent.jar" ]; then
    echo "Downloading OTEL Java agent..."
    mkdir -p ./agent
    cd agent
    wget -O opentelemetry-javaagent.jar \
        https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v2.0.0/opentelemetry-javaagent.jar
    cd ..
    ln -sf agent/opentelemetry-javaagent.jar opentelemetry-javaagent.jar
    echo "OTEL Java agent downloaded successfully!"
else
    echo "OTEL Java agent already exists."
fi

echo ""
echo "=================================="
echo "Building Docker Images"
echo "=================================="

# Build custom Tomcat image with OTEL agent
docker build -t tomcat-otel-app:latest .

echo ""
echo "=================================="
echo "Starting Docker Compose Stack"
echo "=================================="

# Start all services
docker-compose up -d

echo ""
echo "=================================="
echo "Stack Started Successfully!"
echo "=================================="
echo ""
echo "Services URLs:"
echo "  - Application: http://localhost:8080/hello-world-spring-boot-sample-app"
echo "  - Health Check: http://localhost:8080/hello-world-spring-boot-sample-app/health"
echo "  - Metrics: http://localhost:8080/hello-world-spring-boot-sample-app/actuator/prometheus"
echo "  - Jaeger UI: http://localhost:16686"
echo "  - Grafana: http://localhost:3000 (admin/admin123)"
echo "  - Prometheus: http://localhost:9090"
echo ""
echo "To view logs:"
echo "  docker-compose logs -f"
echo ""
echo "To stop the stack:"
echo "  docker-compose down"
echo ""
