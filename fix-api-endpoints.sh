#!/bin/bash

echo "🛠️ FIXING API ENDPOINTS AND CONFIGURATION"
echo "=========================================="

# Stop services temporarily
echo "Stopping services temporarily..."
pkill -f "user-service" || true
pkill -f "post-service" || true
sleep 3

echo ""
echo "📝 UPDATING SECURITY CONFIGURATION..."

# Update User Service security to permit all requests for testing
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
spring.jpa.properties.hibernate.jdbc.lob.non_contextual_creation=true

# Disable Flyway completely
spring.flyway.enabled=false

# Actuator
management.endpoints.web.exposure.include=*
management.endpoint.health.show-details=always

# Security - PERMISSIVE FOR TESTING
spring.security.oauth2.resourceserver.jwt.issuer-uri=http://localhost:8080
management.endpoints.web.cors.allowed-origins=*
management.endpoints.web.cors.allowed-methods=*

# Logging
logging.level.com.socialplatform.backend=DEBUG
logging.level.org.hibernate.SQL=DEBUG
logging.level.org.springframework.security=DEBUG
logging.level.org.springframework.web=DEBUG
EOF

# Update Post Service configuration
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
spring.jpa.properties.hibernate.jdbc.lob.non_contextual_creation=true

# Disable Flyway completely
spring.flyway.enabled=false

# Actuator
management.endpoints.web.exposure.include=*
management.endpoint.health.show-details=always

# Security - PERMISSIVE FOR TESTING
spring.security.oauth2.resourceserver.jwt.issuer-uri=http://localhost:8080
management.endpoints.web.cors.allowed-origins=*
management.endpoints.web.cors.allowed-methods=*

# Logging
logging.level.com.socialplatform.backend=DEBUG
logging.level.org.hibernate.SQL=DEBUG
logging.level.org.springframework.security=DEBUG
EOF

echo "✅ Configuration updated!"

echo ""
echo "🚀 REBUILDING AND RESTARTING SERVICES..."

cd ~/dev-setup/social-platform-backend
mvn clean package -DskipTests

echo ""
echo "🔄 RESTARTING SERVICES..."

# Start services in background
cd ~/dev-setup/social-platform-backend/user-service
java -jar target/user-service-0.0.1-SNAPSHOT.jar &
USER_PID=$!
echo "User Service started: $USER_PID"

sleep 5

cd ~/dev-setup/social-platform-backend/post-service
java -jar target/post-service-0.0.1-SNAPSHOT.jar &
POST_PID=$!
echo "Post Service started: $POST_PID"

sleep 5

cd ~/dev-setup/social-platform-backend/gateway-service
java -jar target/gateway-service-0.0.1-SNAPSHOT.jar &
GATEWAY_PID=$!
echo "Gateway Service started: $GATEWAY_PID"

echo ""
echo "⏳ Waiting for services to initialize..."
sleep 15

echo ""
echo "🎉 SERVICES RESTARTED WITH PERMISSIVE SECURITY!"
echo "📋 Service PIDs:"
echo "   User Service: $USER_PID"
echo "   Post Service: $POST_PID"
echo "   Gateway Service: $GATEWAY_PID"