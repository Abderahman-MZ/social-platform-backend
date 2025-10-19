#!/bin/bash

echo "🔧 FIXING SPRING SECURITY CONFIGURATION"
echo "========================================"

# Stop services
echo "Stopping services..."
pkill -f "user-service" || true
pkill -f "post-service" || true
pkill -f "gateway-service" || true
sleep 3

echo ""
echo "📝 UPDATING SECURITY CONFIGURATION..."

# Update User Service with permissive security
cat > ~/dev-setup/social-platform-backend/user-service/src/main/resources/application.properties << 'EOF'
# Server Configuration
server.port=8081

# Database Configuration
spring.datasource.url=jdbc:postgresql://localhost:5432/social_platform
spring.datasource.username=postgres
spring.datasource.password=OPen

# JPA Configuration
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect

# Disable Flyway
spring.flyway.enabled=false

# Actuator
management.endpoints.web.exposure.include=*
management.endpoint.health.show-details=always

# Security - DISABLE FOR TESTING
spring.autoconfigure.exclude=org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration

# Logging
logging.level.com.socialplatform.backend=DEBUG
logging.level.org.springframework.web=DEBUG
logging.level.org.springframework.security=OFF
EOF

# Update Post Service with permissive security
cat > ~/dev-setup/social-platform-backend/post-service/src/main/resources/application.properties << 'EOF'
# Server Configuration
server.port=8083

# Database Configuration
spring.datasource.url=jdbc:postgresql://localhost:5432/social_platform
spring.datasource.username=postgres
spring.datasource.password=OPen

# JPA Configuration
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect

# Disable Flyway
spring.flyway.enabled=false

# Actuator
management.endpoints.web.exposure.include=*
management.endpoint.health.show-details=always

# Security - DISABLE FOR TESTING
spring.autoconfigure.exclude=org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration

# Logging
logging.level.com.socialplatform.backend=DEBUG
logging.level.org.springframework.web=DEBUG
logging.level.org.springframework.security=OFF
EOF

echo "✅ Security configuration updated!"

echo ""
echo "🔧 REMOVING SECURITY FILTERS..."

# Remove JWT filters that are causing issues
rm -f ~/dev-setup/social-platform-backend/user-service/src/main/java/com/socialplatform/backend/userservice/security/JwtAuthenticationFilter.java
rm -f ~/dev-setup/social-platform-backend/post-service/src/main/java/com/socialplatform/backend/postservice/security/JwtAuthenticationFilter.java

echo ""
echo "🚀 REBUILDING SERVICES..."

cd ~/dev-setup/social-platform-backend
mvn clean package -DskipTests

echo ""
echo "🔄 STARTING SERVICES WITHOUT SECURITY..."

# Start User Service
cd ~/dev-setup/social-platform-backend/user-service
java -jar target/user-service-0.0.1-SNAPSHOT.jar &
USER_PID=$!
echo "User Service started: $USER_PID"

sleep 5

# Start Post Service
cd ~/dev-setup/social-platform-backend/post-service
java -jar target/post-service-0.0.1-SNAPSHOT.jar &
POST_PID=$!
echo "Post Service started: $POST_PID"

sleep 5

# Kill any existing gateway on port 8082
fuser -k 8082/tcp || true

# Start Gateway Service
cd ~/dev-setup/social-platform-backend/gateway-service
java -jar target/gateway-service-0.0.1-SNAPSHOT.jar &
GATEWAY_PID=$!
echo "Gateway Service started: $GATEWAY_PID"

echo ""
echo "⏳ Waiting for services to initialize..."
sleep 15

echo ""
echo "🎉 SERVICES STARTED WITH SECURITY DISABLED!"
echo "📋 Service PIDs:"
echo "   User Service: $USER_PID"
echo "   Post Service: $POST_PID"
echo "   Gateway Service: $GATEWAY_PID"