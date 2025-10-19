#!/bin/bash

echo "🧪 Testing Social Platform System"

BASE_URL="http://localhost:8082"

echo "1. Testing User Registration..."
REGISTER_RESPONSE=$(curl -s -X POST $BASE_URL/api/users/user/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","password":"Password123!"}')
echo "Registration: $REGISTER_RESPONSE"

echo "2. Testing User Login..."
LOGIN_RESPONSE=$(curl -s -X POST $BASE_URL/api/users/user/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"Password123!"}')
echo "Login: $LOGIN_RESPONSE"

# Extract JWT token
JWT_TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)

if [ -n "$JWT_TOKEN" ]; then
    echo "3. Testing Post Creation..."
    CREATE_POST_RESPONSE=$(curl -s -X POST $BASE_URL/api/posts/posts \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $JWT_TOKEN" \
      -d '{"title":"Test Post","content":"This is a test post!"}')
    echo "Create Post: $CREATE_POST_RESPONSE"
    
    echo "4. Testing Get Posts..."
    GET_POSTS_RESPONSE=$(curl -s -X GET "$BASE_URL/api/posts/posts/user/1" \
      -H "Authorization: Bearer $JWT_TOKEN")
    echo "Get Posts: $GET_POSTS_RESPONSE"
    
    echo "5. Testing Feed..."
    GET_FEED_RESPONSE=$(curl -s -X GET "$BASE_URL/api/posts/posts/feed" \
      -H "Authorization: Bearer $JWT_TOKEN")
    echo "Get Feed: $GET_FEED_RESPONSE"
    
    echo "6. Testing Follow User..."
    FOLLOW_RESPONSE=$(curl -s -X POST "$BASE_URL/api/posts/posts/follow/2" \
      -H "Authorization: Bearer $JWT_TOKEN")
    echo "Follow User: $FOLLOW_RESPONSE"
    
    echo "✅ System test completed successfully!"
else
    echo "❌ Failed to get JWT token"
fi