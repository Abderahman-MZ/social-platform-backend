#!/bin/bash

echo "🧪 Testing Social Platform Services Directly"

echo ""
echo "1. Testing User Service (8081)..."
curl -s http://localhost:8081/actuator/health && echo " - ✅ User Service OK" || echo " - ❌ User Service FAILED"

echo ""
echo "2. Testing Post Service (8083)..."
curl -s http://localhost:8083/actuator/health && echo " - ✅ Post Service OK" || echo " - ❌ Post Service FAILED"

echo ""
echo "3. Testing User Registration..."
REGISTER_RESPONSE=$(curl -s -X POST http://localhost:8081/api/users/user/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","password":"Password123!"}')
echo "Registration: $REGISTER_RESPONSE"

echo ""
echo "4. Testing User Login..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8081/api/users/user/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"Password123!"}')
echo "Login: $LOGIN_RESPONSE"

# Extract JWT token
JWT_TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)

if [ -n "$JWT_TOKEN" ]; then
    echo ""
    echo "5. Testing Post Creation..."
    CREATE_POST_RESPONSE=$(curl -s -X POST http://localhost:8083/api/posts/posts \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $JWT_TOKEN" \
      -d '{"title":"Test Post","content":"This is a test post!"}')
    echo "Create Post: $CREATE_POST_RESPONSE"
    
    echo ""
    echo "6. Testing Get Posts..."
    GET_POSTS_RESPONSE=$(curl -s -X GET "http://localhost:8083/api/posts/posts/user/1" \
      -H "Authorization: Bearer $JWT_TOKEN")
    echo "Get Posts: $GET_POSTS_RESPONSE"
    
    echo ""
    echo "✅ All direct service tests completed successfully!"
else
    echo ""
    echo "❌ Failed to get JWT token"
fi