#!/bin/bash

echo "=== CLEANING UP TEST USERS ==="

# Delete test users (be careful with this in production!)
psql -d social_platform_db -U postgres << SQL
DELETE FROM user_profiles WHERE user_id IN (SELECT id FROM users WHERE username LIKE 'testuser_%');
DELETE FROM users WHERE username LIKE 'testuser_%';
SQL

echo "Test users cleaned up"
