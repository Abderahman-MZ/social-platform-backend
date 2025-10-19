#!/bin/bash

echo "🧪 SIMPLE SERVICE TEST (No Authentication)"
echo "=========================================="

sleep 10

echo ""
echo "📊 SERVICE HEALTH CHECKS:"
echo "-------------------------"

# Test User Service Health
echo -n "User Service (8081): "
USER_HEALTH=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8081/actuator/health)
if [ "$USER_HEALTH" = "200" ]; then
    echo "✅ HEALTHY"
else
    echo "❌ UNHEALTHY (Status: $USER_HEALTH)"
fi

# Test Post Service Health
echo -n "Post Service (8083): "
POST_HEALTH=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8083/actuator/health)
if [ "$POST_HEALTH" = "200" ]; then
    echo "✅ HEALTHY"
else
    echo "❌ UNHEALTHY (Status: $POST_HEALTH)"
fi

# Test Gateway Service Health
echo -n "Gateway Service (8082): "
GATEWAY_HEALTH=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8082/actuator/health)
if [ "$GATEWAY_HEALTH" = "200" ]; then
    echo "✅ HEALTHY"
else
    echo "❌ UNHEALTHY (Status: $GATEWAY_HEALTH)"
fi

echo ""
echo "🚀 TESTING BASIC FUNCTIONALITY:"
echo "-------------------------------"

# Test User Registration
echo "1. Testing User Registration..."
REGISTER_RESPONSE=$(curl -s -X POST http://localhost:8081/api/users/user/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@test.com","password":"Password123!"}' || echo "FAILED")

if [[ "$REGISTER_RESPONSE" == *"id"* ]]; then
    USER_ID=$(echo $REGISTER_RESPONSE | grep -o '"id":[0-9]*' | cut -d: -f2)
    echo "   ✅ SUCCESS - User ID: $USER_ID"
    echo "   Response: $REGISTER_RESPONSE"
else
    echo "   ❌ FAILED"
    echo "   Response: $REGISTER_RESPONSE"
fi

# Test User Login
echo "2. Testing User Login..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8081/api/users/user/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"Password123!"}' || echo "FAILED")

if [[ "$LOGIN_RESPONSE" == *"token"* ]]; then
    echo "   ✅ SUCCESS - Login working"
    echo "   Response: $LOGIN_RESPONSE"
else
    echo "   ❌ FAILED"
    echo "   Response: $LOGIN_RESPONSE"
fi

# Test Creating a Post (without auth for now)
echo "3. Testing Post Creation..."
POST_RESPONSE=$(curl -s -X POST http://localhost:8083/api/posts/posts \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Post","content":"This is a test post","userId":1}' || echo "FAILED")

if [[ "$POST_RESPONSE" == *"id"* ]]; then
    echo "   ✅ SUCCESS - Post created"
    echo "   Response: $POST_RESPONSE"
else
    echo "   ❌ FAILED"
    echo "   Response: $POST_RESPONSE"
fi

echo ""
echo "🌐 TESTING GATEWAY:"
echo "-------------------"

# Test Gateway routing
echo "4. Testing Gateway Routing..."
GATEWAY_RESPONSE=$(curl -s -X POST http://localhost:8082/api/users/user/register \
  -H "Content-Type: application/json" \
  -d '{"username":"gatewayuser","email":"gateway@test.com","password":"Password123!"}' || echo "FAILED")

if [[ "$GATEWAY_RESPONSE" == *"id"* ]]; then
    echo "   ✅ SUCCESS - Gateway routing working"
    echo "   Response: $GATEWAY_RESPONSE"
else
    echo "   ❌ FAILED - Gateway routing issue"
    echo "   Response: $GATEWAY_RESPONSE"
fi

echo ""
echo "🎯 TEST SUMMARY:"
echo "----------------"
echo "If all services show ✅ HEALTHY, the basic infrastructure is working!"
echo "We can then re-enable security step by step."