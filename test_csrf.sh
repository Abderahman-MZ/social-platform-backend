#!/bin/bash

echo "=== Testing CSRF Protection ==="

# Base URL
BASE_URL="http://localhost:8082"
COOKIE_FILE="gateway_cookies.txt"

# Clean up any existing cookie file
rm -f $COOKIE_FILE

# Step 1: Get CSRF token by making a GET request to public endpoint
echo "1. Getting CSRF token..."
curl -c $COOKIE_FILE -s $BASE_URL/api/users/user/public

# Step 2: Extract CSRF token from cookies
CSRF_TOKEN=$(grep XSRF-TOKEN $COOKIE_FILE | awk '{print $7}')
echo "2. CSRF Token: $CSRF_TOKEN"

# Step 3: Try to register without CSRF token (should fail)
echo "3. Testing registration WITHOUT CSRF token (should fail)..."
curl -X POST $BASE_URL/api/users/user/register \
     -H "Content-Type: application/json" \
     -d '{"username":"testuser4","email":"test4@example.com","password":"Password123!"}' \
     -w "\nHTTP Status: %{http_code}\n"

# Step 4: Register with CSRF token (should work)
echo "4. Testing registration WITH CSRF token (should work)..."
curl -X POST $BASE_URL/api/users/user/register \
     -H "Content-Type: application/json" \
     -H "X-XSRF-TOKEN: $CSRF_TOKEN" \
     -b $COOKIE_FILE \
     -d '{"username":"testuser4","email":"test4@example.com","password":"Password123!"}' \
     -w "\nHTTP Status: %{http_code}\n"

# Step 5: Login with CSRF token
echo "5. Testing login WITH CSRF token..."
LOGIN_RESPONSE=$(curl -X POST $BASE_URL/api/users/user/login \
     -H "Content-Type: application/json" \
     -H "X-XSRF-TOKEN: $CSRF_TOKEN" \
     -b $COOKIE_FILE \
     -d '{"username":"testuser4","password":"Password123!"}' \
     -w "\nHTTP Status: %{http_code}")

echo "$LOGIN_RESPONSE"

# Clean up
rm -f $COOKIE_FILE

echo "=== Test Complete ==="
