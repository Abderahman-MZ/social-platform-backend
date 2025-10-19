#!/bin/bash

echo "🎯 FINAL COMPREHENSIVE TEST"
echo "==========================="

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 15

echo ""
echo "📊 SERVICE HEALTH CHECK:"
echo "-----------------------"

check_endpoint() {
    local name=$1
    local url=$2
    local method=${3:-GET}
    local data=${4:-}
    
    echo -n "$name: "
    if [ "$method" = "POST" ]; then
        RESPONSE=$(curl -s -X POST "$url" -H "Content-Type: application/json" -d "$data" 2>/dev/null || echo "FAILED")
    else
        RESPONSE=$(curl -s "$url" 2>/dev/null || echo "FAILED")
    fi
    
    if [[ "$RESPONSE" != "FAILED" ]] && [[ "$RESPONSE" != *"error"* ]] && [[ "$RESPONSE" != *"Error"* ]]; then
        echo "✅ SUCCESS"
        echo "   Response: $RESPONSE"
        return 0
    else
        echo "❌ FAILED"
        echo "   Response: $RESPONSE"
        return 1
    fi
}

echo ""
echo "🚀 TESTING DIRECT SERVICE ENDPOINTS:"
echo "-----------------------------------"

# Test User Service directly
check_endpoint "User Service Health" "http://localhost:8081/api/users/health"
check_endpoint "User Service Hello" "http://localhost:8081/api/users/hello"
check_endpoint "User Service Test" "http://localhost:8081/api/users/test"

# Test Post Service directly
check_endpoint "Post Service Health" "http://localhost:8083/api/posts/health"
check_endpoint "Post Service Hello" "http://localhost:8083/api/posts/hello"
check_endpoint "Post Service Test" "http://localhost:8083/api/posts/test"

echo ""
echo "🌐 TESTING GATEWAY ROUTING:"
echo "--------------------------"

# Test Gateway routing
check_endpoint "Gateway → User Service" "http://localhost:8082/api/users/hello"
check_endpoint "Gateway → Post Service" "http://localhost:8082/api/posts/hello"

echo ""
echo "📝 TESTING API FUNCTIONALITY:"
echo "---------------------------"

# Test registration
check_endpoint "User Registration" "http://localhost:8081/api/users/register" "POST" '{"username":"testuser","password":"testpass"}'
check_endpoint "User Login" "http://localhost:8081/api/users/login" "POST" '{"username":"testuser","password":"testpass"}'

# Test post creation
check_endpoint "Post Creation" "http://localhost:8083/api/posts/create" "POST" '{"title":"Test Post","content":"Test Content"}'

echo ""
echo "🔍 TESTING ACTUATOR ENDPOINTS:"
echo "-----------------------------"

check_endpoint "User Service Actuator" "http://localhost:8081/actuator/health"
check_endpoint "Post Service Actuator" "http://localhost:8083/actuator/health"
check_endpoint "Gateway Actuator" "http://localhost:8082/actuator/health"

echo ""
echo "📋 FINAL SUMMARY:"
echo "----------------"
echo "If you see ✅ SUCCESS for most endpoints, your social platform is WORKING!"
echo ""
echo "🎉 AVAILABLE ENDPOINTS:"
echo "   User Service:"
echo "     - GET  http://localhost:8081/api/users/hello"
echo "     - POST http://localhost:8081/api/users/register"
echo "     - POST http://localhost:8081/api/users/login"
echo "   Post Service:"
echo "     - GET  http://localhost:8083/api/posts/hello" 
echo "     - POST http://localhost:8083/api/posts/create"
echo "   Gateway:"
echo "     - GET  http://localhost:8082/api/users/hello"
echo "     - GET  http://localhost:8082/api/posts/hello"