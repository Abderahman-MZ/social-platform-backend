#!/bin/bash

echo "🔧 QUICK API FIX"
echo "================"

# Check running services
echo "📊 Checking running services..."
ps aux | grep -E "(user-service|post-service|gateway-service)" | grep -v grep

echo ""
echo "🔍 Checking service health..."
echo "User Service:"
curl -s http://localhost:8081/actuator/health | jq . 2>/dev/null || curl -s http://localhost:8081/actuator/health
echo ""

echo "Post Service:"
curl -s http://localhost:8083/actuator/health | jq . 2>/dev/null || curl -s http://localhost:8083/actuator/health
echo ""

echo "Gateway Service:"
curl -s http://localhost:8082/actuator/health | jq . 2>/dev/null || curl -s http://localhost:8082/actuator/health
echo ""

# Test direct endpoints
echo "🧪 Testing direct endpoints..."
echo "1. Testing User Service directly:"
curl -s -X POST http://localhost:8081/api/users/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@test.com","password":"Password123!"}' || echo "FAILED"
echo ""

echo "2. Testing Post Service directly:"
curl -s -X GET http://localhost:8083/actuator/info || echo "FAILED"
echo ""

echo "3. Testing Gateway routing:"
curl -s -X GET http://localhost:8082/api/users/actuator/health || echo "FAILED"
echo ""