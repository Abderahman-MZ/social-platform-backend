#!/bin/bash

echo "=== TESTING BASIC GATEWAY FUNCTIONALITY (CSRF DISABLED) ==="

BASE_URL="http://localhost:8082"

echo "1. Testing User-Service Directly..."
curl -s http://localhost:8081/user/public

echo -e "\n2. Testing Gateway Public Endpoint..."
curl -s $BASE_URL/api/users/user/public

echo -e "\n3. Testing Registration Through Gateway (CSRF disabled)..."
REGISTER_RESPONSE=$(curl -X POST $BASE_URL/api/users/user/register \
     -H "Content-Type: application/json" \
     -d '{"username":"testuser9","email":"test9@example.com","password":"Password123!"}' \
     -w "\nHTTP Status: %{http_code}")

echo "$REGISTER_RESPONSE"

echo -e "\n4. Testing Login Through Gateway..."
LOGIN_RESPONSE=$(curl -X POST $BASE_URL/api/users/user/login \
     -H "Content-Type: application/json" \
     -d '{"username":"testuser9","password":"Password123!"}')

echo "Login Response: $LOGIN_RESPONSE"

# Extract JWT token
JWT_TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
if [ -n "$JWT_TOKEN" ]; then
    echo "✅ JWT Token: $JWT_TOKEN"
    
    echo -e "\n5. Testing Protected Endpoint with JWT..."
    PROTECTED_RESPONSE=$(curl -X GET $BASE_URL/api/users/user/profile \
         -H "Authorization: Bearer $JWT_TOKEN" \
         -w "\nHTTP Status: %{http_code}")
    
    echo "Protected: $PROTECTED_RESPONSE"
fi

echo -e "\n=== TEST COMPLETE ==="
