#!/bin/bash

echo "🔧 Applying Quick Fixes..."

# Stop any running services
pkill -f "user-service" || true
pkill -f "post-service" || true
pkill -f "gateway-service" || true

sleep 2

# Update user-service properties to disable Flyway
echo "Updating user-service configuration..."
cat > ~/dev-setup/social-platform-backend/user-service/src/main/resources/application.properties << 'EOF'
# Database Configuration
spring.datasource.url=jdbc:postgresql://localhost:5432/social_platform_db
spring.datasource.username=postgres
spring.datasource.password=OPen
spring.datasource.driver-class-name=org.postgresql.Driver

# JPA Configuration
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect
spring.jpa.properties.hibernate.format_sql=true

# Flyway Configuration - Disable since tables exist
spring.flyway.enabled=false

# Server Configuration
server.port=8081

# JWT Configuration
jwt.secret=your-secret-key-change-in-production-with-at-least-256-bits-long-enough-for-hs256
jwt.expiration=86400000

# Logging
logging.level.com.socialplatform.backend=DEBUG
EOF

# Update gateway-service properties
echo "Updating gateway-service configuration..."
cat > ~/dev-setup/social-platform-backend/gateway-service/src/main/resources/application.properties << 'EOF'
# Server Configuration
server.port=8082

# Spring Cloud Compatibility
spring.cloud.compatibility-verifier.enabled=false
spring.main.allow-bean-definition-overriding=true

# Gateway Routes
spring.cloud.gateway.routes[0].id=user-service
spring.cloud.gateway.routes[0].uri=http://localhost:8081
spring.cloud.gateway.routes[0].predicates[0]=Path=/api/users/**

spring.cloud.gateway.routes[1].id=post-service
spring.cloud.gateway.routes[1].uri=http://localhost:8083
spring.cloud.gateway.routes[1].predicates[0]=Path=/api/posts/**

# Security - Disable for development
spring.security.oauth2.resourceserver.jwt.jwk-set-uri=http://dummy

# Logging
logging.level.org.springframework.cloud.gateway=DEBUG
logging.level.com.socialplatform.backend=DEBUG
EOF

echo "✅ Configuration files updated!"
echo "🚀 Now restart the services using the start script or manually"