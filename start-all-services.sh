#!/bin/bash

echo "🚀 Starting Social Platform Services..."

# Kill any existing services
pkill -f "user-service" || true
pkill -f "post-service" || true
pkill -f "gateway-service" || true

sleep 2

echo "📦 Building services..."
cd ~/dev-setup/social-platform-backend
mvn clean package -DskipTests

echo "🔧 Starting User Service..."
cd user-service
java -jar target/user-service-0.0.1-SNAPSHOT.jar &
USER_PID=$!
cd ..

echo "⏳ Waiting for User Service to initialize database..."
sleep 20

echo "🔧 Starting Post Service..."
cd post-service
java -jar target/post-service-0.0.1-SNAPSHOT.jar &
POST_PID=$!
cd ..

echo "⏳ Waiting for Post Service to start..."
sleep 15

echo "🔧 Starting Gateway Service..."
cd gateway-service
java -jar target/gateway-service-0.0.1-SNAPSHOT.jar &
GATEWAY_PID=$!
cd ..

echo "⏳ Waiting for Gateway Service to start..."
sleep 10

echo "✅ Services started with PIDs:"
echo "   User Service: $USER_PID"
echo "   Post Service: $POST_PID"
echo "   Gateway Service: $GATEWAY_PID"

echo "🔍 Checking service health..."
curl -s http://localhost:8081/actuator/health && echo " - User Service OK" || echo " - User Service FAILED"
curl -s http://localhost:8083/actuator/health && echo " - Post Service OK" || echo " - Post Service FAILED"
curl -s http://localhost:8082/actuator/health && echo " - Gateway Service OK" || echo " - Gateway Service FAILED"

echo "🎉 All services are starting up! Use Ctrl+C to stop all services."

# Wait for Ctrl+C
trap "echo '🛑 Stopping all services...'; kill $USER_PID $POST_PID $GATEWAY_PID; exit" INT
wait