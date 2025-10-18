#!/bin/bash

echo "=== TESTING CSRF TOKEN GENERATION ==="

BASE_URL="http://localhost:8082"
COOKIE_FILE="csrf_test.txt"

# Clean up
rm -f $COOKIE_FILE

echo "1. Making GET request to get CSRF token..."
curl -c $COOKIE_FILE -v http://localhost:8082/api/users/user/public 2>&1 | grep -i "set-cookie\|xsrf"

echo -e "\n2. Checking cookies file:"
cat $COOKIE_FILE

echo -e "\n3. Extracting CSRF token..."
CSRF_TOKEN=$(grep XSRF-TOKEN $COOKIE_FILE | awk '{print $7}')
if [ -n "$CSRF_TOKEN" ]; then
    echo "CSRF Token Found: $CSRF_TOKEN"
else
    echo "ERROR: No CSRF token found!"
    echo "Checking all cookies:"
    cat $COOKIE_FILE
fi

echo -e "\n4. Testing POST without CSRF token (should fail)..."
curl -X POST $BASE_URL/api/users/user/register \
     -H "Content-Type: application/json" \
     -d '{"username":"testuser7","email":"test7@example.com","password":"Password123!"}' \
     -w "\nHTTP Status: %{http_code}\n"

if [ -n "$CSRF_TOKEN" ]; then
    echo -e "\n5. Testing POST with CSRF token (should work)..."
    curl -X POST $BASE_URL/api/users/user/register \
         -H "Content-Type: application/json" \
         -H "X-XSRF-TOKEN: $CSRF_TOKEN" \
         -b $COOKIE_FILE \
         -d '{"username":"testuser7","email":"test7@example.com","password":"Password123!"}' \
         -w "\nHTTP Status: %{http_code}\n"
fi

# Clean up
rm -f $COOKIE_FILE

echo "=== TEST COMPLETE ==="
