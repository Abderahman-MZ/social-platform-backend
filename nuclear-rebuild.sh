#!/bin/bash

echo "💥 NUCLEAR REBUILD - COMPLETE SECURITY REMOVAL"
echo "=============================================="

# Stop everything
echo "Stopping all services..."
pkill -f "java" || true
sleep 3

echo ""
echo "🗑️ REMOVING SECURITY DEPENDENCIES..."

# Remove security dependencies from pom.xml files
cd ~/dev-setup/social-platform-backend

# Update user-service pom.xml to remove security
sed -i '/spring-boot-starter-security/d' user-service/pom.xml
sed -i '/spring-security-test/d' user-service/pom.xml

# Update post-service pom.xml to remove security  
sed -i '/spring-boot-starter-security/d' post-service/pom.xml
sed -i '/spring-security-test/d' post-service/pom.xml

echo "✅ Security dependencies removed!"

echo ""
echo "🔧 CREATING MINIMAL CONFIGURATION..."

# Create minimal application properties for User Service
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

# Disable security
spring.autoconfigure.exclude=org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration

# Actuator
management.endpoints.web.exposure.include=*

# Logging
logging.level.com.socialplatform.backend=DEBUG
EOF

# Create minimal application properties for Post Service
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

# Disable security
spring.autoconfigure.exclude=org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration

# Actuator
management.endpoints.web.exposure.include=*

# Logging
logging.level.com.socialplatform.backend=DEBUG
EOF

echo ""
echo "🚀 REBUILDING FROM SCRATCH..."

mvn clean package -DskipTests

echo ""
echo "🔄 STARTING CLEAN SERVICES..."

# Start User Service
cd user-service
java -jar target/user-service-0.0.1-SNAPSHOT.jar &
USER_PID=$!
echo "User Service: $USER_PID"

sleep 5

# Start Post Service  
cd ../post-service
java -jar target/post-service-0.0.1-SNAPSHOT.jar &
POST_PID=$!
echo "Post Service: $POST_PID"

sleep 5

# Kill any existing gateway and start new
fuser -k 8082/tcp || true
cd ../gateway-service
java -jar target/gateway-service-0.0.1-SNAPSHOT.jar &
GATEWAY_PID=$!
echo "Gateway Service: $GATEWAY_PID"

echo ""
echo "⏳ Waiting for services..."
sleep 15

echo ""
echo "🎉 NUCLEAR REBUILD COMPLETE!"
echo "Services should now be accessible without security restrictions."