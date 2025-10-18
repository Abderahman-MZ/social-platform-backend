#!/bin/bash

echo "=== SIMPLE GATEWAY WORKFLOW TEST ==="

BASE_URL="http://localhost:8082"
TIMESTAMP=$(date +%s)
NEW_USERNAME="testuser_${TIMESTAMP}"
NEW_EMAIL="test${TIMESTAMP}@example.com"

echo "Using test username: $NEW_USERNAME"

echo -e "\n1. Testing Gateway Public Endpoint..."
curl -s $BASE_URL/api/users/user/public
echo ""

echo -e "\n2. Testing Registration Through Gateway..."
curl -s -X POST $BASE_URL/api/users/user/register \
     -H "Content-Type: application/json" \
     -d "{\"username\":\"$NEW_USERNAME\",\"email\":\"$NEW_EMAIL\",\"password\":\"Password123!\"}"
echo ""

echo -e "\n3. Testing Login Through Gateway..."
LOGIN_RESPONSE=$(curl -s -X POST $BASE_URL/api/users/user/login \
     -H "Content-Type: application/json" \
     -d "{\"username\":\"$NEW_USERNAME\",\"password\":\"Password123!\"}")
echo "$LOGIN_RESPONSE"

# Extract JWT token manually
if [[ "$LOGIN_RESPONSE" == *"token"* ]]; then
    TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
    echo "✅ JWT Token: $TOKEN"
    
    echo -e "\n4. Testing Profile Creation..."
    curl -s -X POST $BASE_URL/api/users/user/profile \
         -H "Content-Type: application/json" \
         -H "Authorization: Bearer $TOKEN" \
         -d '{"bio":"Test bio","location":"Test City","profilePictureUrl":"https://example.com/avatar.jpg"}'
    echo ""
    
    echo -e "\n5. Testing Profile Retrieval..."
    curl -s -X GET $BASE_URL/api/users/user/profile \
         -H "Authorization: Bearer $TOKEN"
    echo ""
else
    echo "❌ Failed to get JWT token"
fi

echo -e "\n6. Testing Existing User Login (testuser9)..."
curl -s -X POST $BASE_URL/api/users/user/login \
     -H "Content-Type: application/json" \
     -d '{"username":"testuser9","password":"Password123!"}'
echo ""

echo -e "\n=== TEST COMPLETE ==="
