#!/bin/bash

echo "=== HEALTH CHECK (with correct password) ==="

echo -e "\n1. Service Endpoints:"
echo "User Service Public: $(curl -s -o /dev/null -w "%{http_code}" http://localhost:8081/user/public)"
echo "Gateway Public: $(curl -s -o /dev/null -w "%{http_code}" http://localhost:8082/api/users/user/public)"

echo -e "\n2. Database Health:"
if PGPASSWORD="OPen" psql -d social_platform_db -U postgres -h localhost -c "SELECT 1;" >/dev/null 2>&1; then
    echo "✅ Database is accessible"
    USER_COUNT=$(PGPASSWORD="OPen" psql -d social_platform_db -U postgres -h localhost -t -c "SELECT COUNT(*) FROM users;" 2>/dev/null | tr -d ' ' || echo "N/A")
    PROFILE_COUNT=$(PGPASSWORD="OPen" psql -d social_platform_db -U postgres -h localhost -t -c "SELECT COUNT(*) FROM user_profiles;" 2>/dev/null | tr -d ' ' || echo "N/A")
    echo "   Users: $USER_COUNT, Profiles: $PROFILE_COUNT"
else
    echo "❌ Database is not accessible"
fi

echo -e "\n3. Service Processes:"
jps -l | grep -E "(UserServiceApplication|GatewayServiceApplication)" | while read line; do
    echo "   ✅ $line"
done

echo -e "\n4. Quick Database Preview:"
PGPASSWORD="OPen" psql -d social_platform_db -U postgres -h localhost -c "SELECT id, username, email FROM users ORDER BY id DESC LIMIT 3;" 2>/dev/null || echo "   Could not query users"

echo -e "\n=== HEALTH CHECK COMPLETE ==="
