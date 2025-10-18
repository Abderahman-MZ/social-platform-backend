#!/bin/bash

echo "=== SERVICE MONITOR ==="
echo "Current time: $(date)"

echo -e "\nJava Processes:"
jps -l | grep -E "(UserServiceApplication|GatewayServiceApplication)" || echo "No services running"

echo -e "\nPort Usage:"
sudo netstat -tlnp | grep -E ":8081|:8082" || echo "Ports 8081 and 8082 not in use"

echo -e "\nService Status:"
./quick_status.sh

echo -e "\nRecent Logs:"
echo "User Service (last 5 lines):"
tail -5 user-service.log 2>/dev/null || echo "No user-service.log found"

echo -e "\nGateway Service (last 5 lines):"
tail -5 gateway-service.log 2>/dev/null || echo "No gateway-service.log found"
