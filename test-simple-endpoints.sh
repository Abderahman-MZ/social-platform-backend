#!/bin/bash

echo "🧪 TESTING SIMPLE ENDPOINTS"
echo "============================"

echo ""
echo "⏳ Waiting for services..."
sleep 10

echo ""
echo "🚀 TESTING SIMPLE ENDPOINTS:"
echo "---------------------------"

# Test User Service
echo "1. Testing User Service hello endpoint..."
RESPONSE=$(curl -s http://localhost:8081/api/test/hello || echo "FAILED")
echo "   Response: $RESPONSE"

# Test Post Service
echo "2. Testing Post Service hello endpoint..."
RESPONSE=$(curl -s http://localhost:8083/api/test/hello || echo "FAILED")
echo "   Response: $RESPONSE"

# Test Gateway routing
echo "3. Testing Gateway routing to User Service..."
RESPONSE=$(curl -s http://localhost:8082/api/test/hello || echo "FAILED")
echo "   Response: $RESPONSE"

# Test registration endpoint
echo "4. Testing User Service registration..."
RESPONSE=$(curl -s -X POST http://localhost:8081/api/test/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"test"}' || echo "FAILED")
echo "   Response: $RESPONSE"

# Test post creation endpoint
echo "5. Testing Post Service post creation..."
RESPONSE=$(curl -s -X POST http://localhost:8083/api/test/posts \
  -H "Content-Type: application/json" \
  -d '{"title":"Test","content":"Test"}' || echo "FAILED")
echo "   Response: $RESPONSE"

echo ""
echo "📋 SUMMARY:"
echo "----------"
echo "If you see 'Hello from...' responses, the basic routing is working!"
echo "If you see 'FAILED', we need to fix the security configuration."