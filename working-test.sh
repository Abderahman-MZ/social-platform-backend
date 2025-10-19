#!/bin/bash

echo "🎯 WORKING API TEST WITH CORRECT ENDPOINTS"
echo "=========================================="

echo ""
echo "⏳ Waiting for services to start..."
sleep 10

echo ""
echo "📊 SERVICE HEALTH CHECKS:"
echo "-------------------------"

check_health() {
    local name=$1
    local port=$2
    local url="http://localhost:$port/actuator/health"
    
    echo -n "$name ($port): "
    if curl -s "$url" | grep -q '"status":"UP"'; then
        echo "✅ HEALTHY"
        return 0
    else
        echo "❌ UNHEALTHY"
        return 1
    fi
}

check_health "User Service" "8081"
check_health "Post Service" "8083" 
check_health "Gateway Service" "8082"

echo ""
echo "🚀 TESTING API ENDPOINTS (WITH CORRECT PATHS):"
echo "----------------------------------------------"

# Test User Registration - CORRECT ENDPOINT
echo "1. Testing User Registration..."
REGISTER_RESPONSE=$(curl -s -X POST http://localhost:8081/api/users/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@test.com","password":"Password123!"}' || echo "FAILED")

echo "   Response: $REGISTER_RESPONSE"

if [[ "$REGISTER_RESPONSE" == *"id"* ]] || [[ "$REGISTER_RESPONSE" == *"username"* ]]; then
    echo "   ✅ SUCCESS - User registration working"
    # Extract user ID if possible
    USER_ID=$(echo "$REGISTER_RESPONSE" | grep -o '"id":[0-9]*' | cut -d: -f2 | head -1)
    if [ ! -z "$USER_ID" ]; then
        echo "   User ID: $USER_ID"
    fi
else
    echo "   ❌ FAILED - Registration issue"
fi

# Test User Login - CORRECT ENDPOINT
echo ""
echo "2. Testing User Login..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8081/api/users/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"Password123!"}' || echo "FAILED")

echo "   Response: $LOGIN_RESPONSE"

if [[ "$LOGIN_RESPONSE" == *"token"* ]] || [[ "$LOGIN_RESPONSE" == *"success"* ]]; then
    echo "   ✅ SUCCESS - Login working"
else
    echo "   ❌ FAILED - Login issue"
fi

# Test Post Creation - CORRECT ENDPOINT (using user ID 1 as fallback)
echo ""
echo "3. Testing Post Creation..."
POST_USER_ID=${USER_ID:-1}
POST_RESPONSE=$(curl -s -X POST "http://localhost:8083/api/posts?userId=$POST_USER_ID" \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Post","content":"This is a test post content"}' || echo "FAILED")

echo "   Response: $POST_RESPONSE"

if [[ "$POST_RESPONSE" == *"id"* ]] || [[ "$POST_RESPONSE" == *"title"* ]]; then
    echo "   ✅ SUCCESS - Post creation working"
else
    echo "   ❌ FAILED - Post creation issue"
fi

echo ""
echo "🌐 TESTING GATEWAY ROUTING:"
echo "---------------------------"

# Test Gateway routing
echo "4. Testing Gateway Routing..."
GATEWAY_RESPONSE=$(curl -s -X POST http://localhost:8082/api/users/register \
  -H "Content-Type: application/json" \
  -d '{"username":"gatewayuser","email":"gateway@test.com","password":"Password123!"}' || echo "FAILED")

echo "   Response: $GATEWAY_RESPONSE"

if [[ "$GATEWAY_RESPONSE" == *"id"* ]] || [[ "$GATEWAY_RESPONSE" == *"username"* ]]; then
    echo "   ✅ SUCCESS - Gateway routing working"
else
    echo "   ❌ FAILED - Gateway routing issue"
fi

echo ""
echo "📋 ENDPOINT SUMMARY:"
echo "-------------------"
echo "User Service Direct:"
echo "  Register: POST http://localhost:8081/api/users/register"
echo "  Login:    POST http://localhost:8081/api/users/login"
echo ""
echo "Post Service Direct:"
echo "  Create:   POST http://localhost:8083/api/posts?userId=1"
echo ""
echo "Gateway (Recommended):"
echo "  Register: POST http://localhost:8082/api/users/register"
echo "  Login:    POST http://localhost:8082/api/users/login"
echo "  Posts:    POST http://localhost:8082/api/posts?userId=1"