#!/bin/bash

echo "=== SYSTEM STATUS ==="

# Check User-Service
echo -n "User-Service (8081): "
if curl -s http://localhost:8081/user/public > /dev/null; then
    echo "✅ RUNNING"
else
    echo "❌ NOT RUNNING"
fi

# Check Gateway
echo -n "Gateway (8082): "
if curl -s http://localhost:8082/api/users/user/public > /dev/null; then
    echo "✅ RUNNING"
else
    echo "❌ NOT RUNNING"
fi

# Check Java processes
echo -e "\nJava Processes:"
jps -l | grep -E "(UserServiceApplication|GatewayServiceApplication)" || echo "No gateway/user-service processes found"

echo "=== STATUS CHECK COMPLETE ==="
