#!/bin/bash

echo "🚀 STARTING SERVICES IN FOREGROUND"
echo "==================================="

# Kill any existing services
pkill -f "user-service" || true
pkill -f "post-service" || true
pkill -f "gateway-service" || true

sleep 2

echo "Starting User Service..."
cd ~/dev-setup/social-platform-backend/user-service
java -jar target/user-service-0.0.1-SNAPSHOT.jar &
USER_PID=$!
echo "User Service PID: $USER_PID"

sleep 5

echo "Starting Post Service..."
cd ~/dev-setup/social-platform-backend/post-service
java -jar target/post-service-0.0.1-SNAPSHOT.jar &
POST_PID=$!
echo "Post Service PID: $POST_PID"

sleep 5

echo "Starting Gateway Service..."
cd ~/dev-setup/social-platform-backend/gateway-service
java -jar target/gateway-service-0.0.1-SNAPSHOT.jar &
GATEWAY_PID=$!
echo "Gateway Service PID: $GATEWAY_PID"

echo ""
echo "🎉 ALL SERVICES STARTED IN FOREGROUND!"
echo "📋 Service PIDs:"
echo "   User Service: $USER_PID"
echo "   Post Service: $POST_PID" 
echo "   Gateway Service: $GATEWAY_PID"
echo ""
echo "💡 Press Ctrl+C to stop all services"
echo "🔍 Check logs in separate terminals if needed"

# Wait for user to stop services
wait