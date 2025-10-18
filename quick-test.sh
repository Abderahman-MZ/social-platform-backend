#!/bin/bash
echo "=== Quick Service Test ==="

# Test gateway health
echo "1. Testing Gateway Health..."
curl -s http://localhost:8082/actuator/health | jq '.status' || echo "Gateway not responding"

# Test registration
echo -e "\n2. Testing User Registration..."
REGISTER_RESPONSE=$(curl -s -w "HTTP_STATUS:%{http_code}" -X POST http://localhost:8082/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "quicktest",
    "email": "quick@test.com",
    "password": "password123"
  }')

HTTP_STATUS=$(echo "$REGISTER_RESPONSE" | grep -o 'HTTP_STATUS:[0-9]*' | cut -d: -f2)
RESPONSE_BODY=$(echo "$REGISTER_RESPONSE" | sed 's/HTTP_STATUS:[0-9]*//')

echo "Response: $RESPONSE_BODY"
echo "HTTP Status: $HTTP_STATUS"

if [ "$HTTP_STATUS" = "201" ]; then
    echo "✅ Registration successful!"
    
    # Test login
    echo -e "\n3. Testing User Login..."
    LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8082/api/users/login \
      -H "Content-Type: application/json" \
      -d '{
        "username": "quicktest",
        "password": "password123"
      }')
    
    echo "Login Response: $LOGIN_RESPONSE"
    
    # Extract token
    TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
    if [ -n "$TOKEN" ]; then
        echo "✅ Login successful! Token received."
        echo "Token: $TOKEN"
    else
        echo "❌ Login failed"
    fi
else
    echo "❌ Registration failed"
fi
