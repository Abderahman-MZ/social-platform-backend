#!/bin/bash

echo "=== FINAL CSRF + AUTHENTICATION TEST ==="

BASE_URL="http://localhost:8082"
COOKIE_FILE="final_cookies.txt"

rm -f $COOKIE_FILE

echo "1. Getting CSRF token..."
curl -c $COOKIE_FILE -s $BASE_URL/api/users/user/public > /dev/null

CSRF_TOKEN=$(grep XSRF-TOKEN $COOKIE_FILE | awk '{print $7}')
echo "CSRF Token: $CSRF_TOKEN"

if [ -z "$CSRF_TOKEN" ]; then
    echo "ERROR: No CSRF token available"
    exit 1
fi

echo -e "\n2. Registering user with CSRF token..."
REGISTER_RESPONSE=$(curl -X POST $BASE_URL/api/users/user/register \
     -H "Content-Type: application/json" \
     -H "X-XSRF-TOKEN: $CSRF_TOKEN" \
     -b $COOKIE_FILE \
     -d '{"username":"finaluser","email":"final@example.com","password":"Password123!"}' \
     -w "\n%{http_code}")

echo "Register: $REGISTER_RESPONSE"

echo -e "\n3. Logging in with CSRF token..."
LOGIN_RESPONSE=$(curl -X POST $BASE_URL/api/users/user/login \
     -H "Content-Type: application/json" \
     -H "X-XSRF-TOKEN: $CSRF_TOKEN" \
     -b $COOKIE_FILE \
     -d '{"username":"finaluser","password":"Password123!"}')

echo "Login: $LOGIN_RESPONSE"

# Extract JWT token
JWT_TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
if [ -n "$JWT_TOKEN" ]; then
    echo -e "\n4. JWT Token: $JWT_TOKEN"
    
    echo -e "\n5. Testing protected endpoint with JWT + CSRF..."
    PROTECTED_RESPONSE=$(curl -X GET $BASE_URL/api/users/user/profile \
         -H "Authorization: Bearer $JWT_TOKEN" \
         -H "X-XSRF-TOKEN: $CSRF_TOKEN" \
         -b $COOKIE_FILE \
         -w "\n%{http_code}")
    
    echo "Protected: $PROTECTED_RESPONSE"
fi

rm -f $COOKIE_FILE
echo -e "\n=== TEST COMPLETE ==="
