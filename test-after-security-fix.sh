#!/bin/bash

echo "🧪 TESTING AFTER SECURITY FIX"
echo "=============================="

echo ""
echo "⏳ Waiting for services..."
sleep 10

echo ""
echo "📊 SERVICE HEALTH CHECKS:"
echo "-------------------------"

check_service() {
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

check_service "User Service" "8081"
check_service "Post Service" "8083" 
check_service "Gateway Service" "8082"

echo ""
echo "🚀 TESTING BASIC ENDPOINTS:"
echo "---------------------------"

# Test if we can access actuator endpoints
echo "1. Testing User Service Actuator..."
curl -s http://localhost:8081/actuator | grep -q "_links" && echo "   ✅ User Service accessible" || echo "   ❌ User Service not accessible"

echo "2. Testing Post Service Actuator..."
curl -s http://localhost:8083/actuator | grep -q "_links" && echo "   ✅ Post Service accessible" || echo "   ❌ Post Service not accessible"

echo "3. Testing Gateway Service Actuator..."
curl -s http://localhost:8082/actuator | grep -q "_links" && echo "   ✅ Gateway Service accessible" || echo "   ❌ Gateway Service not accessible"

echo ""
echo "🔍 CHECKING CONTROLLER MAPPINGS:"
echo "-------------------------------"

echo "4. Checking User Service endpoints..."
curl -s http://localhost:8081/actuator/mappings | grep -o '"pattern":"/[^"]*' | head -10

echo "5. Checking Post Service endpoints..."
curl -s http://localhost:8083/actuator/mappings | grep -o '"pattern":"/[^"]*' | head -10

echo ""
echo "🎯 SIMPLE API TEST:"
echo "------------------"

# Test if we can hit any API endpoint
echo "6. Testing any User Service API endpoint..."
RESPONSE=$(curl -s -X GET http://localhost:8081/ || echo "NO_RESPONSE")
if [[ "$RESPONSE" != "NO_RESPONSE" ]]; then
    echo "   ✅ User Service responding"
else
    echo "   ❌ User Service not responding"
fi

echo "7. Testing any Post Service API endpoint..."
RESPONSE=$(curl -s -X GET http://localhost:8083/ || echo "NO_RESPONSE")
if [[ "$RESPONSE" != "NO_RESPONSE" ]]; then
    echo "   ✅ Post Service responding"
else
    echo "   ❌ Post Service not responding"
fi

echo ""
echo "📋 SUMMARY:"
echo "----------"
echo "If services show ✅ HEALTHY and endpoints are accessible,"
echo "the security fix worked! We can now focus on API development."