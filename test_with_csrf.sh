#!/bin/bash

# Base URL
BASE_URL="http://localhost:8082"
COOKIE_FILE="gateway_cookies.txt"

# Get CSRF token
echo "Getting CSRF token..."
CSRF_RESPONSE=$(curl -c $COOKIE_FILE -s $BASE_URL/api/users/user/public)
CSRF_TOKEN=$(grep -oP 'XSRF-TOKEN=\K[^;]+' $COOKIE_FILE 2>/dev/null)

if [ -z "$CSRF_TOKEN" ]; then
    echo "Failed to get CSRF token"
    exit 1
fi

echo "CSRF Token: $CSRF_TOKEN"

# Register user
echo "Registering user..."
REGISTER_RESPONSE=$(curl -X POST $BASE_URL/api/users/user/register \
     -H "Content-Type: application/json" \
     -H "X-XSRF-TOKEN: $CSRF_TOKEN" \
     -b $COOKIE_FILE \
     -d '{"username":"gatewayuser2","email":"gateway2@example.com","password":"Password123!"}' \
     -w "\n%{http_code}")

echo "Register response: $REGISTER_RESPONSE"

# Login
echo "Logging in..."
LOGIN_RESPONSE=$(curl -X POST $BASE_URL/api/users/user/login \
     -H "Content-Type: application/json" \
     -H "X-XSRF-TOKEN: $CSRF_TOKEN" \
     -b $COOKIE_FILE \
     -d '{"username":"gatewayuser2","password":"Password123!"}')

echo "Login response: $LOGIN_RESPONSE"

# Extract JWT token from login response
JWT_TOKEN=$(echo $LOGIN_RESPONSE | grep -oP '"token":"\K[^"]+')
echo "JWT Token: $JWT_TOKEN"

# Clean up
rm -f $COOKIE_FILE
