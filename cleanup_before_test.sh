#!/bin/bash

echo "=== CLEANING UP TEST USERS BEFORE TEST ==="

PGPASSWORD="OPen" psql -d social_platform_db -U postgres -h localhost << SQL
-- Delete user profiles for test users
DELETE FROM user_profiles 
WHERE user_id IN (
    SELECT id FROM users 
    WHERE username LIKE 'testuser_%' 
    OR username = 'testuser9'
);

-- Delete test users
DELETE FROM users 
WHERE username LIKE 'testuser_%' 
OR username = 'testuser9';

-- Show remaining users
SELECT COUNT(*) as remaining_users FROM users;
SQL

echo "Cleanup complete"
