#!/bin/bash

echo "🧪 TESTING DATABASE CONNECTION"
echo "=============================="

echo "1. Testing PostgreSQL connection..."
psql -h localhost -U postgres -d social_platform -c "SELECT version();" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "   ✅ PostgreSQL connection successful"
else
    echo "   ❌ PostgreSQL connection failed"
    echo "   Please check if PostgreSQL is running and password is correct"
    exit 1
fi

echo ""
echo "2. Checking database tables..."
psql -h localhost -U postgres -d social_platform -c "\dt" 2>/dev/null

echo ""
echo "3. Testing User Service database connection..."
curl -s http://localhost:8081/actuator/health | grep -q "UP" && echo "   ✅ User Service DB connection" || echo "   ❌ User Service DB connection failed"

echo ""
echo "4. Testing Post Service database connection..."
curl -s http://localhost:8083/actuator/health | grep -q "UP" && echo "   ✅ Post Service DB connection" || echo "   ❌ Post Service DB connection failed"

echo ""
echo "📋 SUMMARY:"
echo "If all tests show ✅, the database connection is working!"