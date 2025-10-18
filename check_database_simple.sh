#!/bin/bash

echo "=== DATABASE CHECK ==="

# Check if PostgreSQL is running
if ! pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
    echo "❌ PostgreSQL is not running"
    exit 1
fi

echo "✅ PostgreSQL is running"

# Check users in database
echo -e "\n1. Current Users in Database:"
psql -d social_platform_db -U postgres -c "SELECT id, username, email, role, created_at FROM users ORDER BY created_at DESC LIMIT 5;" 2>/dev/null || echo "Failed to query users"

echo -e "\n2. User Profiles:"
psql -d social_platform_db -U postgres -c "SELECT up.id, u.username, up.bio, up.location FROM user_profiles up JOIN users u ON up.user_id = u.id;" 2>/dev/null || echo "Failed to query profiles"

echo -e "\n3. User Count:"
psql -d social_platform_db -U postgres -c "SELECT COUNT(*) as total_users FROM users;" 2>/dev/null || echo "Failed to count users"

echo "=== DATABASE CHECK COMPLETE ==="
