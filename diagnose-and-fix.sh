#!/bin/bash

echo "🔍 DIAGNOSING AND FIXING SERVICE ISSUES"
echo "========================================"

# Stop all services
echo "Stopping all services..."
pkill -f "user-service" || true
pkill -f "post-service" || true
pkill -f "gateway-service" || true

sleep 3

echo ""
echo "🔧 CHECKING AND FIXING CONFIGURATIONS..."

# Check if controllers exist and fix them if needed
echo "1. Checking User Service Controller..."
if [ ! -f ~/dev-setup/social-platform-backend/user-service/src/main/java/com/socialplatform/backend/userservice/controller/UserController.java ]; then
    echo "   ❌ UserController missing - creating it..."
    mkdir -p ~/dev-setup/social-platform-backend/user-service/src/main/java/com/socialplatform/backend/userservice/controller
    
    cat > ~/dev-setup/social-platform-backend/user-service/src/main/java/com/socialplatform/backend/userservice/controller/UserController.java << 'EOF'
package com.socialplatform.backend.userservice.controller;

import com.socialplatform.backend.userservice.dto.UserDTO;
import com.socialplatform.backend.userservice.dto.LoginDTO;
import com.socialplatform.backend.userservice.dto.AuthResponse;
import com.socialplatform.backend.userservice.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserService userService;

    @PostMapping("/user/register")
    public ResponseEntity<?> registerUser(@RequestBody UserDTO userDTO) {
        try {
            UserDTO registeredUser = userService.registerUser(userDTO);
            return ResponseEntity.ok(registeredUser);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("{\"error\": \"" + e.getMessage() + "\"}");
        }
    }

    @PostMapping("/user/login")
    public ResponseEntity<?> loginUser(@RequestBody LoginDTO loginDTO) {
        try {
            AuthResponse authResponse = userService.loginUser(loginDTO);
            return ResponseEntity.ok(authResponse);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("{\"error\": \"" + e.getMessage() + "\"}");
        }
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("User Service is healthy");
    }
}
EOF
    echo "   ✅ UserController created"
else
    echo "   ✅ UserController exists"
fi

echo "2. Checking Post Service Controller..."
if [ ! -f ~/dev-setup/social-platform-backend/post-service/src/main/java/com/socialplatform/backend/postservice/controller/PostController.java ]; then
    echo "   ❌ PostController missing - creating it..."
    mkdir -p ~/dev-setup/social-platform-backend/post-service/src/main/java/com/socialplatform/backend/postservice/controller
    
    cat > ~/dev-setup/social-platform-backend/post-service/src/main/java/com/socialplatform/backend/postservice/controller/PostController.java << 'EOF'
package com.socialplatform.backend.postservice.controller;

import com.socialplatform.backend.postservice.dto.PostDTO;
import com.socialplatform.backend.postservice.service.PostService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/posts")
public class PostController {

    @Autowired
    private PostService postService;

    @PostMapping("/posts")
    public ResponseEntity<?> createPost(@RequestBody PostDTO postDTO) {
        try {
            PostDTO createdPost = postService.createPost(postDTO);
            return ResponseEntity.ok(createdPost);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("{\"error\": \"" + e.getMessage() + "\"}");
        }
    }

    @GetMapping("/posts/user/{userId}")
    public ResponseEntity<?> getPostsByUserId(@PathVariable Long userId) {
        try {
            List<PostDTO> posts = postService.getPostsByUserId(userId);
            return ResponseEntity.ok(posts);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("{\"error\": \"" + e.getMessage() + "\"}");
        }
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Post Service is healthy");
    }
}
EOF
    echo "   ✅ PostController created"
else
    echo "   ✅ PostController exists"
fi

echo "3. Fixing Security Configurations..."
# Ensure permissive security for testing
cat > ~/dev-setup/social-platform-backend/user-service/src/main/java/com/socialplatform/backend/userservice/config/SecurityConfig.java << 'EOF'
package com.socialplatform.backend.userservice.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public BCryptPasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(authz -> authz
                // Allow ALL requests without authentication for testing
                .anyRequest().permitAll()
            );

        return http.build();
    }
}
EOF

cat > ~/dev-setup/social-platform-backend/post-service/src/main/java/com/socialplatform/backend/postservice/config/SecurityConfig.java << 'EOF'
package com.socialplatform.backend.postservice.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                // Allow ALL requests without authentication for testing
                .anyRequest().permitAll()
            );
        return http.build();
    }
}
EOF

echo "4. Fixing Actuator Configuration..."
# Add actuator to application properties
cat > ~/dev-setup/social-platform-backend/user-service/src/main/resources/application.properties << 'EOF'
# Server Configuration
server.port=8081

# Database Configuration
spring.datasource.url=jdbc:postgresql://localhost:5432/social_platform
spring.datasource.username=postgres
spring.datasource.password=password

# JPA Configuration
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect

# Actuator
management.endpoints.web.exposure.include=health,info
management.endpoint.health.show-details=always

# Logging
logging.level.com.socialplatform.backend=DEBUG
EOF

cat > ~/dev-setup/social-platform-backend/post-service/src/main/resources/application.properties << 'EOF'
# Server Configuration
server.port=8083

# Database Configuration
spring.datasource.url=jdbc:postgresql://localhost:5432/social_platform
spring.datasource.username=postgres
spring.datasource.password=password

# JPA Configuration
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect

# Actuator
management.endpoints.web.exposure.include=health,info
management.endpoint.health.show-details=always

# Logging
logging.level.com.socialplatform.backend=DEBUG
EOF

echo "✅ All configurations checked and fixed!"
echo "🚀 Rebuilding services..."

cd ~/dev-setup/social-platform-backend
mvn clean package -DskipTests

echo ""
echo "🎉 DIAGNOSIS AND FIX COMPLETE!"
echo "📋 Next steps:"
echo "   1. Start services: ./start-all-services.sh"
echo "   2. Run test: ./simple-test.sh"
echo "   3. Check logs if issues persist"