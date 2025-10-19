#!/bin/bash

echo "=== Complete Profile Workflow Test ==="

# 1. Register
echo "1. Registering user..."
REGISTER_RESPONSE=$(curl -s -X POST http://localhost:8082/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "profileuser",
    "email": "profile@test.com",
    "password": "password123"
  }')

echo "Registration: $REGISTER_RESPONSE"

# 2. Login
echo -e "\n2. Logging in..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8082/api/users/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "profileuser",
    "password": "password123"
  }')

echo "Login: $LOGIN_RESPONSE"

# Extract token
TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
echo "Token: $TOKEN"

if [ -n "$TOKEN" ]; then
    # 3. Create Profile
    echo -e "\n3. Creating profile..."
    CREATE_PROFILE=$(curl -s -X POST http://localhost:8082/api/users/user/profile \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN" \
      -d '{
        "bio": "This is my test bio",
        "location": "Test City",
        "profilePictureUrl": "https://example.com/avatar.jpg"
      }')
    
    echo "Create Profile: $CREATE_PROFILE"
    
    # 4. Get Profile
    echo -e "\n4. Getting profile..."
    GET_PROFILE=$(curl -s -X GET http://localhost:8082/api/users/user/profile \
      -H "Authorization: Bearer $TOKEN")
    
    echo "Get Profile: $GET_PROFILE"
    
    # 5. Update Profile
    echo -e "\n5. Updating profile..."
    UPDATE_PROFILE=$(curl -s -X PUT http://localhost:8082/api/users/user/profile \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN" \
      -d '{
        "bio": "Updated bio with new info",
        "location": "Updated City"
      }')
    
    echo "Update Profile: $UPDATE_PROFILE"
    
    echo -e "\n🎉 Profile workflow completed successfully!"
else
    echo "❌ Failed to get token"
fi
