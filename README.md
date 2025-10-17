# Social Platform Backend

## Overview
Backend for the social platform, built with Java/Spring Boot, connected to PostgreSQL and Firebase.

## Setup Instructions
- Install Java 21 (via SDKMAN) and Maven
- Run `mvn clean install` to build
- Run `mvn spring-boot:run` to start locally

## Directory Structure
- `src/main/java`: Java source code
- `pom.xml`: Maven dependencies
- `Dockerfile`: Container configuration

## CI/CD
- Jenkins pipeline builds and tests on push to `main`

## Contributing
- Fork, branch (feature/*), submit PR to `main`
- Requires review by team member

## Database Connection and JPA Setup
- Configured Spring Data JPA with PostgreSQL for `user-service`
- Added `User` and `Post` JPA entities with proper annotations
- Set up Flyway migrations for database versioning
- Fixed code conflicts and import mismatches
- Practiced Git merge conflict resolution
- Committed with professional Git workflows (branch, PR, review)
