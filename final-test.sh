#!/bin/bash
echo "=== FINAL COMPREHENSIVE TEST ==="

echo "1. Testing Public Endpoint:"
curl -s http://localhost:8082/api/users/user/public | jq .

echo -e "\n2. Testing User Registration:"
REGISTER=$(curl -s -w "HTTP_STATUS:%{http_code}" -X POST http://localhost:8082/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "finaluser",
    "email": "final@test.com",
    "password": "password123"
  }')

HTTP_STATUS=$(echo "$REGISTER" | grep -o 'HTTP_STATUS:[0-9]*' | cut -d: -f2)
RESPONSE=$(echo "$REGISTER" | sed 's/HTTP_STATUS:[0-9]*//')

echo "Response: $RESPONSE"
echo "HTTP Status: $HTTP_STATUS"

if [ "$HTTP_STATUS" = "201" ]; then
    echo "✅ Registration successful!"
    
    echo -e "\n3. Testing User Login:"
    LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8082/api/users/login \
      -H "Content-Type: application/json" \
      -d '{
        "username": "finaluser",
        "password": "password123"
      }')
    
    echo "Login Response: $LOGIN_RESPONSE"
    
    TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
    if [ -n "$TOKEN" ]; then
        echo "✅ Login successful! Token received."
        echo "Token: ${TOKEN:0:20}..."
    else
        echo "❌ Login failed - no token received"
    fi
else
    echo "❌ Registration failed"
fi
