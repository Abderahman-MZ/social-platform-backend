#!/bin/bash

echo "🔧 Applying Comprehensive Fixes..."

# Stop any running services
echo "Stopping all services..."
pkill -f "user-service" || true
pkill -f "post-service" || true
pkill -f "gateway-service" || true

sleep 3

echo "Updating security configurations..."

# Update User Service Security Config
cat > ~/dev-setup/social-platform-backend/user-service/src/main/java/com/socialplatform/backend/userservice/config/SecurityConfig.java << 'EOF'
package com.socialplatform.backend.userservice.config;

import com.socialplatform.backend.userservice.security.JwtAuthenticationFilter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
public class SecurityConfig {
    private static final Logger logger = LoggerFactory.getLogger(SecurityConfig.class);

    @Bean
    public BCryptPasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public JwtAuthenticationFilter jwtAuthenticationFilter() {
        return new JwtAuthenticationFilter();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        logger.info("Configuring Spring Security");

        http
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(authz -> authz
                // Allow public access to authentication endpoints
                .requestMatchers("/api/users/user/register", "/api/users/user/login", "/actuator/health").permitAll()
                .requestMatchers("/api/users/public/**").permitAll()
                // Secure all other endpoints
                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtAuthenticationFilter(), UsernamePasswordAuthenticationFilter.class)
            .exceptionHandling(exceptions -> exceptions
                .authenticationEntryPoint((request, response, authException) -> {
                    logger.warn("Authentication failed for request: {} {}", 
                               request.getMethod(), request.getRequestURI());
                    response.setStatus(401);
                    response.setContentType("application/json");
                    response.getWriter().write("{\"error\": \"Authentication required\"}");
                })
            );

        return http.build();
    }
}
EOF

# Update Post Service Security Config
cat > ~/dev-setup/social-platform-backend/post-service/src/main/java/com/socialplatform/backend/postservice/config/SecurityConfig.java << 'EOF'
package com.socialplatform.backend.postservice.config;

import com.socialplatform.backend.postservice.security.JwtAuthenticationFilter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private JwtAuthenticationFilter jwtAuthenticationFilter;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                // Allow health checks without authentication
                .requestMatchers("/actuator/health").permitAll()
                .requestMatchers("/api/posts/public/**").permitAll()
                // Secure all other endpoints
                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)
            .exceptionHandling(exceptions -> exceptions
                .authenticationEntryPoint((request, response, authException) -> {
                    response.setStatus(401);
                    response.setContentType("application/json");
                    response.getWriter().write("{\"error\": \"Authentication required\"}");
                })
            );
        return http.build();
    }
}
EOF

# Update Gateway Service Configuration
cat > ~/dev-setup/social-platform-backend/gateway-service/src/main/resources/application.properties << 'EOF'
# Server Configuration
server.port=8082

# Spring Cloud Compatibility
spring.cloud.compatibility-verifier.enabled=false
spring.main.allow-bean-definition-overriding=true
spring.main.web-application-type=reactive

# Gateway Routes
spring.cloud.gateway.routes[0].id=user-service
spring.cloud.gateway.routes[0].uri=http://localhost:8081
spring.cloud.gateway.routes[0].predicates[0]=Path=/api/users/**

spring.cloud.gateway.routes[1].id=post-service
spring.cloud.gateway.routes[1].uri=http://localhost:8083
spring.cloud.gateway.routes[1].predicates[0]=Path=/api/posts/**

# Disable database for gateway (it doesn't need it)
spring.autoconfigure.exclude=org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration,org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration,org.springframework.boot.autoconfigure.jdbc.DataSourceTransactionManagerAutoConfiguration,org.springframework.boot.autoconfigure.flyway.FlywayAutoConfiguration

# Logging
logging.level.org.springframework.cloud.gateway=DEBUG
logging.level.com.socialplatform.backend=DEBUG
EOF

echo "✅ All configurations updated!"
echo "🚀 Rebuilding and starting services..."

# Rebuild services
cd ~/dev-setup/social-platform-backend
mvn clean package -DskipTests

echo "🎉 Ready to start services! Run: ./start-all-services.sh"