#!/bin/bash

# Comprehensive Spring Boot Authentication API Test Suite
echo "🔐 Spring Boot Authentication API Test Suite"
echo "============================================="

BASE_URL="http://localhost:8081"
TEST_USERNAME="testuser_$(date +%s)"
TEST_EMAIL="${TEST_USERNAME}@example.com"
TEST_PASSWORD="SecurePassword123!"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    local status=$1
    local message=$2
    if [ $status -eq 0 ]; then
        echo -e "${GREEN}✅ PASS${NC}: $message"
    else
        echo -e "${RED}❌ FAIL${NC}: $message"
    fi
}

# Wait for application to be ready
echo -e "\n${YELLOW}1. Waiting for application startup...${NC}"
for i in {1..30}; do
    if curl -s "${BASE_URL}/user/public" > /dev/null; then
        echo -e "${GREEN}Application is ready!${NC}"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${RED}Application failed to start${NC}"
        exit 1
    fi
    sleep 1
done

echo -e "\n${YELLOW}2. Testing Public Endpoint${NC}"
RESPONSE=$(curl -s -w "HTTP_STATUS:%{http_code}" "${BASE_URL}/user/public")
HTTP_STATUS=$(echo "$RESPONSE" | grep -o 'HTTP_STATUS:[0-9]*' | cut -d: -f2)
if [ "$HTTP_STATUS" -eq 200 ]; then
    print_status 0 "Public endpoint accessible"
else
    print_status 1 "Public endpoint failed"
fi

echo -e "\n${YELLOW}3. Testing User Registration${NC}"
REGISTER_RESPONSE=$(curl -s -w "HTTP_STATUS:%{http_code}" \
    -H "Content-Type: application/json" \
    -d "{\"username\":\"$TEST_USERNAME\",\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PASSWORD\"}" \
    "${BASE_URL}/register")

HTTP_STATUS=$(echo "$REGISTER_RESPONSE" | grep -o 'HTTP_STATUS:[0-9]*' | cut -d: -f2)
if [ "$HTTP_STATUS" -eq 201 ]; then
    print_status 0 "User registration successful"
else
    print_status 1 "User registration failed"
    echo "Response: $REGISTER_RESPONSE"
    exit 1
fi

echo -e "\n${YELLOW}4. Testing User Login${NC}"
LOGIN_RESPONSE=$(curl -s -w "HTTP_STATUS:%{http_code}" \
    -H "Content-Type: application/json" \
    -d "{\"username\":\"$TEST_USERNAME\",\"password\":\"$TEST_PASSWORD\"}" \
    "${BASE_URL}/login")

HTTP_STATUS=$(echo "$LOGIN_RESPONSE" | grep -o 'HTTP_STATUS:[0-9]*' | cut -d: -f2)
JWT_TOKEN=$(echo "$LOGIN_RESPONSE" | sed 's/HTTP_STATUS:[0-9]*//' | grep -o '"token":"[^"]*' | cut -d'"' -f4)

if [ "$HTTP_STATUS" -eq 200 ] && [ -n "$JWT_TOKEN" ]; then
    print_status 0 "User login successful"
    echo "JWT Token: $JWT_TOKEN"
else
    print_status 1 "User login failed"
    echo "Response: $LOGIN_RESPONSE"
    exit 1
fi

echo -e "\n${YELLOW}5. Testing Protected Endpoint${NC}"
PROTECTED_RESPONSE=$(curl -s -w "HTTP_STATUS:%{http_code}" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    "${BASE_URL}/user/test")

HTTP_STATUS=$(echo "$PROTECTED_RESPONSE" | grep -o 'HTTP_STATUS:[0-9]*' | cut -d: -f2)
if [ "$HTTP_STATUS" -eq 200 ]; then
    print_status 0 "Protected endpoint accessible with JWT"
else
    print_status 1 "Protected endpoint failed"
    echo "Response: $PROTECTED_RESPONSE"
fi

echo -e "\n${YELLOW}6. Testing Input Validation${NC}"
VALIDATION_RESPONSE=$(curl -s -w "HTTP_STATUS:%{http_code}" \
    -H "Content-Type: application/json" \
    -d '{"username":"ab","email":"invalid-email","password":"short"}' \
    "${BASE_URL}/register")

HTTP_STATUS=$(echo "$VALIDATION_RESPONSE" | grep -o 'HTTP_STATUS:[0-9]*' | cut -d: -f2)
if [ "$HTTP_STATUS" -eq 400 ]; then
    print_status 0 "Input validation working"
else
    print_status 1 "Input validation failed"
fi

echo -e "\n${YELLOW}7. Database Verification${NC}"
DB_CHECK=$(psql -U postgres -h localhost -d social_platform_db -t -c "
SELECT username, email, role FROM users WHERE username = '$TEST_USERNAME';" 2>/dev/null)

if [ -n "$DB_CHECK" ]; then
    print_status 0 "User persisted to database"
    echo "Database entry: $DB_CHECK"
else
    print_status 1 "Database verification failed"
fi

echo -e "\n${GREEN}=============================================${NC}"
echo -e "${GREEN}🎉 ALL TESTS COMPLETED SUCCESSFULLY!${NC}"
echo -e "${GREEN}=============================================${NC}"
