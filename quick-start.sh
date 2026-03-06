#!/bin/bash

# Quick Start Guide for OpenTelemetry Spring Boot on Tomcat

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║   OpenTelemetry Spring Boot on Tomcat - Quick Start Guide      ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

echo "📍 Step 1: Verify all services are running"
echo "────────────────────────────────────────────"
docker compose ps
echo ""

echo "📍 Step 2: Test the application"
echo "────────────────────────────────────────────"
echo "Testing main endpoint..."
curl -s http://localhost:8080/hello-world-spring-boot-sample-app/ | head -c 100
echo ""
echo ""

echo "Testing API endpoint..."
curl -s http://localhost:8080/hello-world-spring-boot-sample-app/api/hello
echo ""
echo ""

echo "Testing health endpoint..."
curl -s http://localhost:8080/hello-world-spring-boot-sample-app/health | jq .
echo ""

echo "📍 Step 3: Access the UIs"
echo "────────────────────────────────────────────"
echo "✓ Application (main): http://localhost:8080/hello-world-spring-boot-sample-app/"
echo "✓ Jaeger UI (traces): http://localhost:16686"
echo "✓ Grafana (metrics): http://localhost:3000 (admin/admin123)"
echo "✓ Prometheus (storage): http://localhost:9090"
echo ""

echo "📍 Step 4: Generate test traffic (optional)"
echo "────────────────────────────────────────────"
echo "Run this command to generate load:"
echo ""
echo "for i in {1..20}; do"
echo "  curl -s http://localhost:8080/hello-world-spring-boot-sample-app/api/hello/User\$i > /dev/null"
echo "  sleep 0.5"
echo "done"
echo ""

echo "📍 Configuration"
echo "────────────────────────────────────────────"
echo "Service Name: hello-world-spring-boot-sample-app"
echo "Environment: SANDBOX"
echo "Version: 1.0.0"
echo ""

echo "📍 Key Files"
echo "────────────────────────────────────────────"
echo "✓ Source Code: app/src/main/java/com/example/helloworld/"
echo "✓ WAR Package: app/target/hello-world-spring-boot-sample-app-1.0.0.war"
echo "✓ OTEL Agent: agent/opentelemetry-javaagent.jar (v1.32.0)"
echo "✓ Config: app/src/main/resources/application.properties"
echo ""

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    🎉 All Ready to Go! 🎉                      ║"
echo "╚════════════════════════════════════════════════════════════════╝"
