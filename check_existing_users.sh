#!/bin/bash

echo "=== EXISTING USERS IN DATABASE ==="

PGPASSWORD="OPen" psql -d social_platform_db -U postgres -h localhost << SQL
SELECT 
    u.id,
    u.username,
    u.email,
    u.role,
    u.created_at,
    CASE WHEN up.id IS NOT NULL THEN 'Yes' ELSE 'No' END as has_profile
FROM users u
LEFT JOIN user_profiles up ON u.id = up.user_id
ORDER BY u.created_at DESC
LIMIT 10;
SQL
