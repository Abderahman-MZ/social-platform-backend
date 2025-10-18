#!/bin/bash

echo "Stopping any existing services..."
pkill -f "spring-boot:run" || true
sleep 2

echo "Cleaning and compiling..."
mvn clean compile -q

echo "Starting User Service..."
cd user-service
mvn spring-boot:run -Dspring-boot.run.main-class=com.socialplatform.backend.userservice.UserServiceApplication &
USER_PID=$!
cd ..

echo "Waiting for User Service to start..."
sleep 10

echo "Starting Gateway Service..."
cd gateway-service
mvn spring-boot:run -Dspring-boot.run.main-class=com.socialplatform.backend.gatewayservice.GatewayServiceApplication &
GATEWAY_PID=$!
cd ..

echo "Waiting for Gateway Service to start..."
sleep 10

echo "Testing services..."
./status.sh

echo "Services started!"
echo "User Service PID: $USER_PID"
echo "Gateway Service PID: $GATEWAY_PID"
