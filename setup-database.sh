#!/bin/bash

echo "🗄️ SETTING UP POSTGRESQL DATABASE"
echo "=================================="

# Connect to PostgreSQL and create database if it doesn't exist
sudo -u postgres psql << EOF
CREATE DATABASE social_platform;
\c social_platform

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create posts table
CREATE TABLE IF NOT EXISTS posts (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    user_id INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- List tables to verify
\dt
EOF

echo "✅ Database setup complete!"
echo "📊 Database: social_platform"
echo "📋 Tables: users, posts"