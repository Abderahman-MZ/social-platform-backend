#!/bin/bash

echo "=== STARTING ALL SERVICES ==="

# Stop any running services first
echo "Stopping any existing services..."
pkill -f "spring-boot:run" 2>/dev/null || true
sleep 2

# Check if services are still running
echo "Checking for remaining processes..."
jps -l | grep -E "(UserServiceApplication|GatewayServiceApplication)" && echo "Services still running, forcing kill..." && pkill -9 -f "spring-boot:run"

echo -e "\nStarting User Service..."
cd user-service
mvn spring-boot:run > ../user-service.log 2>&1 &
USER_PID=$!
cd ..

echo "Waiting for User Service to start (10 seconds)..."
sleep 10

echo -e "\nStarting Gateway Service..."
cd gateway-service
mvn spring-boot:run > ../gateway-service.log 2>&1 &
GATEWAY_PID=$!
cd ..

echo "Waiting for Gateway Service to start (10 seconds)..."
sleep 10

echo -e "\nChecking service status..."
./quick_status.sh

echo -e "\nService PIDs:"
echo "User Service: $USER_PID"
echo "Gateway Service: $GATEWAY_PID"

echo -e "\nLog files created:"
echo "- user-service.log"
echo "- gateway-service.log"

echo -e "\n=== SERVICES STARTED ==="
