package com.example.helloworld;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.context.annotation.Bean;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Counter;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

/**
 * Spring Boot Application with OpenTelemetry instrumentation
 * Deployable on Tomcat as a WAR file
 */
@SpringBootApplication
public class HelloWorldApplication extends SpringBootServletInitializer {

    public static void main(String[] args) {
        SpringApplication.run(HelloWorldApplication.class, args);
    }
}

/**
 * REST Controller for Hello World endpoints
 */
@RestController
class HelloWorldController {

    private final MeterRegistry meterRegistry;
    private final Counter requestCounter;

    public HelloWorldController(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
        this.requestCounter = Counter.builder("hello_world_requests_total")
                .description("Total number of requests to hello endpoint")
                .tag("service", "hello-world-spring-boot-sample-app")
                .register(meterRegistry);
    }

    @GetMapping("/")
    public String home() {
        requestCounter.increment();
        return "Hello World! Service: hello-world-spring-boot-sample-app";
    }

    @GetMapping("/api/hello")
    public String helloApi() {
        requestCounter.increment();
        return "{\"message\": \"Hello from Spring Boot with OpenTelemetry\", \"service\": \"hello-world-spring-boot-sample-app\"}";
    }

    @GetMapping("/api/hello/{name}")
    public String helloWithName(@PathVariable String name) {
        requestCounter.increment();
        return "{\"message\": \"Hello " + name + "\", \"service\": \"hello-world-spring-boot-sample-app\"}";
    }

    @GetMapping("/health")
    public String health() {
        return "{\"status\": \"UP\", \"service\": \"hello-world-spring-boot-sample-app\"}";
    }

    @GetMapping("/info")
    public String info() {
        return "{\"service\": \"hello-world-spring-boot-sample-app\", \"version\": \"1.0.0\", \"environment\": \"SANDBOX\"}";
    }
}
