#!/bin/bash

echo "=== Testing Social Platform Profile Endpoints ==="

# 1. Register a new user
echo "1. Registering a new user..."
REGISTER_RESPONSE=$(curl -s -X POST http://localhost:8082/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "profiletestuser",
    "email": "profiletest@example.com",
    "password": "password123"
  }')

echo "Register Response: $REGISTER_RESPONSE"

# 2. Login to get token
echo -e "\n2. Logging in to get JWT token..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8082/api/users/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "profiletestuser",
    "password": "password123"
  }')

echo "Login Response: $LOGIN_RESPONSE"

# Extract token from login response
TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
echo "Token: $TOKEN"

if [ -z "$TOKEN" ]; then
    echo "ERROR: Failed to get token"
    exit 1
fi

# 3. Create user profile
echo -e "\n3. Creating user profile..."
CREATE_PROFILE_RESPONSE=$(curl -s -X POST http://localhost:8082/api/users/user/profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "bio": "This is a test bio for profile testing",
    "location": "Test City",
    "profilePictureUrl": "https://example.com/avatar.jpg"
  }')

echo "Create Profile Response: $CREATE_PROFILE_RESPONSE"

# 4. Get user profile
echo -e "\n4. Getting user profile..."
GET_PROFILE_RESPONSE=$(curl -s -X GET http://localhost:8082/api/users/user/profile \
  -H "Authorization: Bearer $TOKEN")

echo "Get Profile Response: $GET_PROFILE_RESPONSE"

# 5. Update user profile
echo -e "\n5. Updating user profile..."
UPDATE_PROFILE_RESPONSE=$(curl -s -X PUT http://localhost:8082/api/users/user/profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "bio": "Updated bio with new information",
    "location": "Updated City"
  }')

echo "Update Profile Response: $UPDATE_PROFILE_RESPONSE"

# 6. Get updated profile
echo -e "\n6. Getting updated profile..."
GET_UPDATED_RESPONSE=$(curl -s -X GET http://localhost:8082/api/users/user/profile \
  -H "Authorization: Bearer $TOKEN")

echo "Get Updated Profile Response: $GET_UPDATED_RESPONSE"

echo -e "\n=== Test Complete ==="
