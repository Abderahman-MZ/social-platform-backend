#!/bin/bash

echo "=== TESTING CSRF WORKFLOW ==="

BASE_URL="http://localhost:8082"
COOKIE_FILE="csrf_test.txt"

rm -f $COOKIE_FILE

echo "1. Getting CSRF token via GET request..."
curl -c $COOKIE_FILE -s $BASE_URL/api/users/user/public > /dev/null

echo -e "\n2. Checking cookies:"
cat $COOKIE_FILE

CSRF_TOKEN=$(grep XSRF-TOKEN $COOKIE_FILE | awk '{print $7}')
if [ -n "$CSRF_TOKEN" ]; then
    echo "✅ CSRF Token: $CSRF_TOKEN"
    
    echo -e "\n3. Testing POST with CSRF token..."
    REGISTER_RESPONSE=$(curl -X POST $BASE_URL/api/users/user/register \
         -H "Content-Type: application/json" \
         -H "X-XSRF-TOKEN: $CSRF_TOKEN" \
         -b $COOKIE_FILE \
         -d '{"username":"csrfuser","email":"csrf@example.com","password":"Password123!"}' \
         -w "\nHTTP Status: %{http_code}")
    
    echo "$REGISTER_RESPONSE"
    
    echo -e "\n4. Testing login with CSRF token..."
    LOGIN_RESPONSE=$(curl -X POST $BASE_URL/api/users/user/login \
         -H "Content-Type: application/json" \
         -H "X-XSRF-TOKEN: $CSRF_TOKEN" \
         -b $COOKIE_FILE \
         -d '{"username":"csrfuser","password":"Password123!"}')
    
    echo "Login: $LOGIN_RESPONSE"
else
    echo "❌ No CSRF token found"
    echo "Testing POST without CSRF (should fail)..."
    curl -X POST $BASE_URL/api/users/user/register \
         -H "Content-Type: application/json" \
         -d '{"username":"failuser","email":"fail@example.com","password":"Password123!"}' \
         -w "\nHTTP Status: %{http_code}\n"
fi

rm -f $COOKIE_FILE
echo -e "\n=== TEST COMPLETE ==="
