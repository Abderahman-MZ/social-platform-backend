#!/bin/bash

echo "=== COMPREHENSIVE CSRF TEST ==="
echo "Testing CSRF token generation and usage..."

BASE_URL="http://localhost:8082"
COOKIE_FILE="csrf_cookies.txt"

# Clean up
rm -f $COOKIE_FILE

echo -e "\n1. Testing GET request to generate CSRF token..."
echo "Request: curl -c $COOKIE_FILE $BASE_URL/api/users/user/public"
RESPONSE=$(curl -c $COOKIE_FILE -s $BASE_URL/api/users/user/public)
echo "Response: $RESPONSE"

echo -e "\n2. Checking cookies file content:"
if [ -f "$COOKIE_FILE" ]; then
    cat $COOKIE_FILE
    echo ""
else
    echo "No cookie file created!"
fi

# Check for CSRF token
CSRF_TOKEN=$(grep XSRF-TOKEN $COOKIE_FILE | awk '{print $7}')
if [ -n "$CSRF_TOKEN" ]; then
    echo "✅ CSRF Token Found: $CSRF_TOKEN"
else
    echo "❌ No CSRF token found in cookies"
    echo "Checking for any cookies:"
    ls -la $COOKIE_FILE 2>/dev/null || echo "No cookie file"
fi

echo -e "\n3. Testing POST without CSRF token (should fail with 403)..."
echo "Request: POST /api/users/user/register (without CSRF)"
curl -X POST $BASE_URL/api/users/user/register \
     -H "Content-Type: application/json" \
     -d '{"username":"testuser8","email":"test8@example.com","password":"Password123!"}' \
     -w "\nHTTP Status: %{http_code}\n"

if [ -n "$CSRF_TOKEN" ]; then
    echo -e "\n4. Testing POST with CSRF token (should work)..."
    echo "Request: POST /api/users/user/register (with CSRF: $CSRF_TOKEN)"
    REGISTER_RESPONSE=$(curl -X POST $BASE_URL/api/users/user/register \
         -H "Content-Type: application/json" \
         -H "X-XSRF-TOKEN: $CSRF_TOKEN" \
         -b $COOKIE_FILE \
         -d '{"username":"testuser8","email":"test8@example.com","password":"Password123!"}' \
         -w "\nHTTP Status: %{http_code}")
    
    echo "$REGISTER_RESPONSE"
    
    # If registration successful, test login
    if echo "$REGISTER_RESPONSE" | grep -q "200" || echo "$REGISTER_RESPONSE" | grep -q "201"; then
        echo -e "\n5. Testing login with CSRF token..."
        LOGIN_RESPONSE=$(curl -X POST $BASE_URL/api/users/user/login \
             -H "Content-Type: application/json" \
             -H "X-XSRF-TOKEN: $CSRF_TOKEN" \
             -b $COOKIE_FILE \
             -d '{"username":"testuser8","password":"Password123!"}')
        
        echo "Login Response: $LOGIN_RESPONSE"
        
        # Extract JWT token
        JWT_TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
        if [ -n "$JWT_TOKEN" ]; then
            echo "✅ JWT Token: $JWT_TOKEN"
        fi
    fi
else
    echo -e "\n4. Skipping POST with CSRF (no token available)"
fi

# Clean up
rm -f $COOKIE_FILE

echo -e "\n=== TEST COMPLETE ==="
