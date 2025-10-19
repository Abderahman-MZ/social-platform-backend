#!/bin/bash

echo "🧪 Quick Service Test"

echo ""
echo "1. Testing User Service Health..."
USER_HEALTH=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8081/actuator/health)
if [ "$USER_HEALTH" = "200" ]; then
    echo "   ✅ User Service Health: OK"
else
    echo "   ❌ User Service Health: FAILED (Status: $USER_HEALTH)"
fi

echo ""
echo "2. Testing Post Service Health..."
POST_HEALTH=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8083/actuator/health)
if [ "$POST_HEALTH" = "200" ]; then
    echo "   ✅ Post Service Health: OK"
else
    echo "   ❌ Post Service Health: FAILED (Status: $POST_HEALTH)"
fi

echo ""
echo "3. Testing User Registration..."
REGISTER_RESPONSE=$(curl -s -X POST http://localhost:8081/api/users/user/register \
  -H "Content-Type: application/json" \
  -d '{"username":"quicktest","email":"quick@test.com","password":"Password123!"}' || echo "FAILED")
  
if [[ "$REGISTER_RESPONSE" == *"id"* ]]; then
    echo "   ✅ User Registration: SUCCESS"
    echo "   Response: $REGISTER_RESPONSE"
else
    echo "   ❌ User Registration: FAILED"
    echo "   Response: $REGISTER_RESPONSE"
fi

echo ""
echo "4. Testing User Login..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8081/api/users/user/login \
  -H "Content-Type: application/json" \
  -d '{"username":"quicktest","password":"Password123!"}' || echo "FAILED")

if [[ "$LOGIN_RESPONSE" == *"token"* ]]; then
    echo "   ✅ User Login: SUCCESS"
    JWT_TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)
    echo "   Token received: ${JWT_TOKEN:0:20}..."
else
    echo "   ❌ User Login: FAILED"
    echo "   Response: $LOGIN_RESPONSE"
fi