FROM tomcat:10.1-jdk17

# Download OpenTelemetry Java agent
RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/*

RUN wget -O /usr/local/tomcat/opentelemetry-javaagent.jar \
    https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v2.0.0/opentelemetry-javaagent.jar

# Remove default ROOT application
RUN rm -rf /usr/local/tomcat/webapps/ROOT

# Set Java options for OTEL
ENV CATALINA_OPTS="-javaagent:/usr/local/tomcat/opentelemetry-javaagent.jar \
    -Dotel.javaagent.debug=false \
    -Dotel.service.name=hello-world-spring-boot-sample-app \
    -Dotel.resource.attributes=deployment.environment=SANDBOX,service.name=hello-world-spring-boot-sample-app,service.version=1.0.0 \
    -Dotel.traces.exporter=otlp \
    -Dotel.metrics.exporter=otlp \
    -Dotel.logs.exporter=otlp"

EXPOSE 8080
