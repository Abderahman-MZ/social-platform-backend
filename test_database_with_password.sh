#!/bin/bash

echo "=== DATABASE CONNECTION TEST WITH PASSWORD ==="

# Test database connection with the correct password
echo "1. Testing database connection..."
PGPASSWORD="OPen" psql -d social_platform_db -U postgres -h localhost -c "SELECT version();" 2>/dev/null && echo "✅ Database connected successfully" || echo "❌ Database connection failed"

echo "2. Checking database contents..."
echo -e "\nCurrent Users:"
PGPASSWORD="OPen" psql -d social_platform_db -U postgres -h localhost -c "SELECT id, username, email, created_at FROM users ORDER BY created_at DESC LIMIT 5;" 2>/dev/null || echo "Failed to query users"

echo -e "\nUser Profiles:"
PGPASSWORD="OPen" psql -d social_platform_db -U postgres -h localhost -c "SELECT up.id, u.username, up.bio, up.location FROM user_profiles up JOIN users u ON up.user_id = u.id;" 2>/dev/null || echo "No profiles found"

echo -e "\nTable counts:"
PGPASSWORD="OPen" psql -d social_platform_db -U postgres -h localhost -c "SELECT 'users' as table_name, COUNT(*) FROM users UNION SELECT 'user_profiles', COUNT(*) FROM user_profiles;" 2>/dev/null || echo "Failed to get counts"
