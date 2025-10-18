#!/bin/bash
echo "=== QUICK START ==="

# Kill existing services
sudo pkill -f java 2>/dev/null
sleep 3

# Install parent POM
mvn clean install -N -q

# Start User Service
cd user-service
echo "Starting User Service..."
nohup mvn spring-boot:run > /tmp/user-service.log 2>&1 &
echo "User Service starting... check /tmp/user-service.log for details"

# Wait and start Gateway
sleep 20
cd ../gateway-service
echo "Starting Gateway Service..."
nohup mvn spring-boot:run > /tmp/gateway-service.log 2>&1 &
echo "Gateway Service starting... check /tmp/gateway-service.log for details"

echo "Services starting in background. Check logs for details."
echo "Test with: curl -X POST http://localhost:8082/api/users/register -H 'Content-Type: application/json' -d '{\"username\":\"test\",\"email\":\"test@test.com\",\"password\":\"password123\"}'"
