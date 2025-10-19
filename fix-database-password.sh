#!/bin/bash

echo "🔧 FIXING DATABASE PASSWORD CONFIGURATION"
echo "=========================================="

# Stop all services
echo "Stopping all services..."
pkill -f "user-service" || true
pkill -f "post-service" || true
pkill -f "gateway-service" || true

sleep 3

echo ""
echo "📝 UPDATING DATABASE CONFIGURATIONS..."

# Update User Service database configuration with correct password
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

# Disable Flyway for now to avoid migration issues
spring.flyway.enabled=false

# Actuator
management.endpoints.web.exposure.include=health,info
management.endpoint.health.show-details=always

# Logging
logging.level.com.socialplatform.backend=DEBUG
EOF

# Update Post Service database configuration with correct password
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

# Disable Flyway for now to avoid migration issues
spring.flyway.enabled=false

# Actuator
management.endpoints.web.exposure.include=health,info
management.endpoint.health.show-details=always

# Logging
logging.level.com.socialplatform.backend=DEBUG
EOF

echo "✅ Database configurations updated with password: OPen"
echo "🚀 Rebuilding services..."

cd ~/dev-setup/social-platform-backend
mvn clean package -DskipTests

echo ""
echo "🎉 DATABASE PASSWORD FIX COMPLETE!"
echo "📋 Next steps:"
echo "   1. Make sure PostgreSQL is running: sudo systemctl start postgresql"
echo "   2. Start services: ./start-all-services.sh"
echo "   3. Run test: ./simple-test.sh"