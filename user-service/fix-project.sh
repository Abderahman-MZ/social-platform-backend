#!/bin/bash

echo "=== Fixing User Service Project ==="

# Create directories
echo "Creating directories..."
mkdir -p src/main/java/com/socialplatform/backend/userservice/model
mkdir -p src/main/java/com/socialplatform/backend/userservice/repository

# Create User.java
echo "Creating User.java..."
cat > src/main/java/com/socialplatform/backend/userservice/model/User.java << 'EOF'
package com.socialplatform.backend.userservice.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 50)
    private String username;

    @Column(nullable = false, unique = true, length = 100)
    private String email;

    @Column(name = "password_hash", nullable = false, length = 255)
    private String passwordHash;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
EOF

# Create UserRepository.java
echo "Creating UserRepository.java..."
cat > src/main/java/com/socialplatform/backend/userservice/repository/UserRepository.java << 'EOF'
package com.socialplatform.backend.userservice.repository;

import com.socialplatform.backend.userservice.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);
    Optional<User> findByEmail(String email);
}
EOF

# Create H2 application.properties
echo "Creating application.properties..."
cat > src/main/resources/application.properties << 'EOF'
server.port=8081
spring.datasource.url=jdbc:h2:mem:testdb
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=
spring.h2.console.enabled=true
spring.h2.console.path=/h2-console
spring.jpa.hibernate.ddl-auto=create-drop
spring.jpa.show-sql=true
spring.flyway.enabled=false
logging.level.com.socialplatform.backend.userservice=DEBUG
EOF

echo "=== Files created successfully ==="
echo "Running Maven compile..."
mvn clean compile -DskipTests

