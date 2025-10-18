#!/bin/bash

echo "=== COMPLETE CSRF PROTECTION TEST ==="
echo "Testing: User-Service (8081) + Gateway (8082) with CSRF"

BASE_URL="http://localhost:8082"
COOKIE_FILE="gateway_cookies.txt"

# Clean up
rm -f $COOKIE_FILE

echo "1. Testing User-Service Directly (No CSRF needed)..."
curl -s http://localhost:8081/user/public

echo -e "\n2. Testing Gateway Public Endpoint (GET - No CSRF needed)..."
RESPONSE=$(curl -c $COOKIE_FILE -s $BASE_URL/api/users/user/public)
echo "Gateway Response: $RESPONSE"

echo -e "\n3. Checking CSRF Cookie..."
cat $COOKIE_FILE

# Extract CSRF token
CSRF_TOKEN=$(grep XSRF-TOKEN $COOKIE_FILE | awk '{print $7}')
echo -e "\n4. CSRF Token: $CSRF_TOKEN"

if [ -z "$CSRF_TOKEN" ]; then
    echo "ERROR: No CSRF token found!"
    exit 1
fi

echo -e "\n5. Testing Registration WITHOUT CSRF Token (Should FAIL)..."
curl -X POST $BASE_URL/api/users/user/register \
     -H "Content-Type: application/json" \
     -d '{"username":"testuser6","email":"test6@example.com","password":"Password123!"}' \
     -w "\nHTTP Status: %{http_code}\n"

echo -e "\n6. Testing Registration WITH CSRF Token (Should WORK)..."
REGISTER_RESPONSE=$(curl -X POST $BASE_URL/api/users/user/register \
     -H "Content-Type: application/json" \
     -H "X-XSRF-TOKEN: $CSRF_TOKEN" \
     -b $COOKIE_FILE \
     -d '{"username":"testuser6","email":"test6@example.com","password":"Password123!"}' \
     -w "\nHTTP Status: %{http_code}")

echo "$REGISTER_RESPONSE"

echo -e "\n7. Testing Login WITH CSRF Token..."
LOGIN_RESPONSE=$(curl -X POST $BASE_URL/api/users/user/login \
     -H "Content-Type: application/json" \
     -H "X-XSRF-TOKEN: $CSRF_TOKEN" \
     -b $COOKIE_FILE \
     -d '{"username":"testuser6","password":"Password123!"}' \
     -w "\nHTTP Status: %{http_code}")

echo "$LOGIN_RESPONSE"

# Extract JWT token if successful
if echo "$LOGIN_RESPONSE" | grep -q "token"; then
    JWT_TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
    echo -e "\n8. JWT Token Received: $JWT_TOKEN"
    
    # Test profile creation with JWT + CSRF
    echo -e "\n9. Testing Profile Creation (JWT + CSRF)..."
    PROFILE_RESPONSE=$(curl -X POST $BASE_URL/api/users/user/profile \
         -H "Content-Type: application/json" \
         -H "X-XSRF-TOKEN: $CSRF_TOKEN" \
         -H "Authorization: Bearer $JWT_TOKEN" \
         -b $COOKIE_FILE \
         -d '{"bio":"Test bio","profilePictureUrl":"https://example.com/photo.jpg","location":"Test City"}' \
         -w "\nHTTP Status: %{http_code}")
    
    echo "$PROFILE_RESPONSE"
fi

# Clean up
rm -f $COOKIE_FILE

echo -e "\n=== TEST COMPLETE ==="
