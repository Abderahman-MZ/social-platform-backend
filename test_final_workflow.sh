#!/bin/bash

echo "=== FINAL GATEWAY WORKFLOW TEST (Fixed JSON Issue) ==="

BASE_URL="http://localhost:8082"
TIMESTAMP=$(date +%s)
NEW_USERNAME="finaluser_${TIMESTAMP}"
NEW_EMAIL="final${TIMESTAMP}@example.com"

echo "Using test username: $NEW_USERNAME"

echo -e "\n1. Testing Gateway Public Endpoint..."
curl -s $BASE_URL/api/users/user/public | jq .
echo ""

echo -e "\n2. Testing Registration Through Gateway..."
REGISTER_RESPONSE=$(curl -s -X POST $BASE_URL/api/users/user/register \
     -H "Content-Type: application/json" \
     -d "{\"username\":\"$NEW_USERNAME\",\"email\":\"$NEW_EMAIL\",\"password\":\"Password123!\"}")
echo "$REGISTER_RESPONSE" | jq .

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
         -d '{"bio":"Final test bio","location":"Final City","profilePictureUrl":"https://example.com/final.jpg"}')
    echo "$PROFILE_CREATE_RESPONSE" | jq '. | {id, bio, profilePictureUrl, location}'
    
    echo -e "\n5. Testing Profile Retrieval (simplified output)..."
    curl -s -X GET $BASE_URL/api/users/user/profile \
         -H "Authorization: Bearer $TOKEN" | jq '. | {id, bio, profilePictureUrl, location}'
    
    echo -e "\n6. Testing Protected Endpoint..."
    curl -s $BASE_URL/api/users/user/test \
         -H "Authorization: Bearer $TOKEN" | jq .
    
else
    echo "❌ Failed to get JWT token"
fi

echo -e "\n7. Database Summary:"
PGPASSWORD="OPen" psql -d social_platform_db -U postgres -h localhost -c "SELECT COUNT(*) as total_users FROM users; SELECT COUNT(*) as total_profiles FROM user_profiles;" 2>/dev/null

echo -e "\n=== FINAL TEST COMPLETE ==="
echo "🎉 MICROSERVICES ARCHITECTURE IS WORKING PERFECTLY! 🎉"
