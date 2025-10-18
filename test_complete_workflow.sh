#!/bin/bash

echo "=== COMPLETE GATEWAY WORKFLOW TEST ==="

BASE_URL="http://localhost:8082"
TIMESTAMP=$(date +%s)
NEW_USERNAME="testuser_${TIMESTAMP}"
NEW_EMAIL="test${TIMESTAMP}@example.com"

echo "Using test username: $NEW_USERNAME"

echo -e "\n1. Testing Gateway Public Endpoint..."
curl -s $BASE_URL/api/users/user/public | jq .

echo -e "\n2. Testing Registration Through Gateway..."
REGISTER_RESPONSE=$(curl -s -X POST $BASE_URL/api/users/user/register \
     -H "Content-Type: application/json" \
     -d "{\"username\":\"$NEW_USERNAME\",\"email\":\"$NEW_EMAIL\",\"password\":\"Password123!\"}" \
     -w "\nHTTP Status: %{http_code}")

echo "$REGISTER_RESPONSE"

echo -e "\n3. Testing Login Through Gateway..."
LOGIN_RESPONSE=$(curl -s -X POST $BASE_URL/api/users/user/login \
     -H "Content-Type: application/json" \
     -d "{\"username\":\"$NEW_USERNAME\",\"password\":\"Password123!\"}")

echo "$LOGIN_RESPONSE" | jq .

# Extract JWT token
TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.token')
if [ "$TOKEN" != "null" ] && [ -n "$TOKEN" ]; then
    echo "✅ JWT Token obtained successfully"
    
    echo -e "\n4. Testing Profile Creation..."
    PROFILE_CREATE_RESPONSE=$(curl -s -X POST $BASE_URL/api/users/user/profile \
         -H "Content-Type: application/json" \
         -H "Authorization: Bearer $TOKEN" \
         -d '{"bio":"Test bio","location":"Test City","profilePictureUrl":"https://example.com/avatar.jpg"}' \
         -w "\nHTTP Status: %{http_code}")
    
    echo "$PROFILE_CREATE_RESPONSE"
    
    echo -e "\n5. Testing Profile Retrieval..."
    PROFILE_GET_RESPONSE=$(curl -s -X GET $BASE_URL/api/users/user/profile \
         -H "Authorization: Bearer $TOKEN")
    
    echo "$PROFILE_GET_RESPONSE" | jq .
    
else
    echo "❌ Failed to get JWT token"
fi

echo -e "\n6. Testing Existing User Login (testuser9)..."
EXISTING_LOGIN=$(curl -s -X POST $BASE_URL/api/users/user/login \
     -H "Content-Type: application/json" \
     -d '{"username":"testuser9","password":"Password123!"}')

echo "$EXISTING_LOGIN" | jq .

echo -e "\n=== TEST COMPLETE ==="
