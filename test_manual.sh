#!/bin/bash

echo "=== MANUAL GATEWAY TEST (No Dependencies) ==="

BASE_URL="http://localhost:8082"
echo "Testing against: $BASE_URL"

echo -e "\n1. Testing if services are reachable..."
echo -n "User Service: "
curl -s -o /dev/null -w "%{http_code}" http://localhost:8081/user/public
echo ""

echo -n "Gateway: "
curl -s -o /dev/null -w "%{http_code}" http://localhost:8082/api/users/user/public
echo ""

echo -e "\n2. Testing public endpoint through gateway..."
curl -s $BASE_URL/api/users/user/public
echo ""

echo -e "\n3. Testing registration with new user..."
NEW_USER="user_$(date +%s)"
curl -s -X POST $BASE_URL/api/users/user/register \
     -H "Content-Type: application/json" \
     -d "{\"username\":\"$NEW_USER\",\"email\":\"${NEW_USER}@test.com\",\"password\":\"test123\"}"
echo ""

echo -e "\n4. Testing login..."
LOGIN_RESPONSE=$(curl -s -X POST $BASE_URL/api/users/user/login \
     -H "Content-Type: application/json" \
     -d "{\"username\":\"$NEW_USER\",\"password\":\"test123\"}")
echo "$LOGIN_RESPONSE"

echo -e "\n=== MANUAL TEST COMPLETE ==="
