#!/bin/bash

echo "=== QUICK STATUS CHECK ==="

# Check User-Service
echo -n "User-Service (8081): "
if curl -s http://localhost:8081/user/public > /dev/null; then
    echo "✅ RUNNING"
    echo "   Public endpoint response:"
    curl -s http://localhost:8081/user/public | head -c 100
    echo ""
else
    echo "❌ NOT RUNNING"
fi

# Check Gateway
echo -n "Gateway (8082): "
if curl -s http://localhost:8082/api/users/user/public > /dev/null; then
    echo "✅ RUNNING"
    echo "   Public endpoint response:"
    curl -s http://localhost:8082/api/users/user/public | head -c 100
    echo ""
else
    echo "❌ NOT RUNNING"
fi

# Check Database
echo -n "Database: "
if psql -d social_platform_db -U postgres -c "SELECT 1;" >/dev/null 2>&1; then
    echo "✅ ACCESSIBLE"
else
    echo "❌ NOT ACCESSIBLE"
fi

echo "=== STATUS CHECK COMPLETE ==="
