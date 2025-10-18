#!/bin/bash

echo "=== DATABASE CHECK ==="

# Check users in database
echo -e "\n1. Current Users in Database:"
psql -d social_platform_db -U postgres -c "SELECT id, username, email, role, created_at FROM users ORDER BY created_at DESC LIMIT 5;"

echo -e "\n2. User Profiles:"
psql -d social_platform_db -U postgres -c "SELECT up.id, u.username, up.bio, up.location FROM user_profiles up JOIN users u ON up.user_id = u.id;"

echo -e "\n3. User Count:"
psql -d social_platform_db -U postgres -c "SELECT COUNT(*) as total_users FROM users;"

echo -e "\n4. Profile Count:"
psql -d social_platform_db -U postgres -c "SELECT COUNT(*) as total_profiles FROM user_profiles;"

echo "=== DATABASE CHECK COMPLETE ==="
