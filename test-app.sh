#!/bin/bash

# Quick test script for the Spring Boot application

echo "Testing Hello World Spring Boot Application with OTEL..."
echo ""

BASE_URL="http://localhost:8080/hello-world-spring-boot-sample-app"

echo "1. Testing home endpoint..."
curl -s "$BASE_URL/" | head -c 100
echo ""
echo ""

echo "2. Testing API hello endpoint..."
curl -s "$BASE_URL/api/hello" | jq . 2>/dev/null || curl -s "$BASE_URL/api/hello"
echo ""

echo "3. Testing API hello with name..."
curl -s "$BASE_URL/api/hello/TestUser" | jq . 2>/dev/null || curl -s "$BASE_URL/api/hello/TestUser"
echo ""

echo "4. Testing health endpoint..."
curl -s "$BASE_URL/health" | jq . 2>/dev/null || curl -s "$BASE_URL/health"
echo ""

echo "5. Testing info endpoint..."
curl -s "$BASE_URL/info" | jq . 2>/dev/null || curl -s "$BASE_URL/info"
echo ""

echo "6. Testing metrics endpoint (first 50 lines)..."
curl -s "$BASE_URL/actuator/prometheus" | head -50
echo ""
echo "..."
echo ""

echo "=================================="
echo "Testing Complete!"
echo "=================================="
echo ""
echo "Access the monitoring UIs:"
echo "  - Jaeger UI: http://localhost:16686"
echo "  - Grafana: http://localhost:3000 (admin/admin123)"
echo "  - Prometheus: http://localhost:9090"
