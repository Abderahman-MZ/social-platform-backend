#!/bin/bash

case "$1" in
    start)
        echo "Starting all services..."
        ./start_services.sh
        ;;
    stop)
        echo "Stopping all services..."
        pkill -f "spring-boot:run"
        echo "Services stopped"
        ;;
    status)
        echo "=== SERVICE STATUS ==="
        jps -l | grep -E "(UserServiceApplication|GatewayServiceApplication)" || echo "No services running"
        echo ""
        echo "=== PORT USAGE ==="
        netstat -tln | grep -E ":8081|:8082" || echo "Ports 8081 and 8082 are free"
        ;;
    test)
        echo "Running quick test..."
        curl -s http://localhost:8082/api/users/user/public | jq '.'
        ;;
    logs)
        echo "=== USER SERVICE LOGS (last 10 lines) ==="
        tail -10 user-service.log 2>/dev/null || echo "No log file"
        echo ""
        echo "=== GATEWAY SERVICE LOGS (last 10 lines) ==="
        tail -10 gateway-service.log 2>/dev/null || echo "No log file"
        ;;
    db-stats)
        echo "=== DATABASE STATISTICS ==="
        PGPASSWORD="OPen" psql -d social_platform_db -U postgres -h localhost << SQL
SELECT 
    'Users' as type, COUNT(*) as count FROM users
UNION ALL
SELECT 
    'Profiles', COUNT(*) FROM user_profiles
UNION ALL  
SELECT
    'Latest User', MAX(username) FROM users;
SQL
        ;;
    *)
        echo "Usage: $0 {start|stop|status|test|logs|db-stats}"
        echo "  start    - Start all services"
        echo "  stop     - Stop all services" 
        echo "  status   - Check service status"
        echo "  test     - Quick functionality test"
        echo "  logs     - Show service logs"
        echo "  db-stats - Show database statistics"
        exit 1
        ;;
esac
