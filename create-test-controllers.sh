#!/bin/bash

echo "🔧 CREATING SIMPLE TEST CONTROLLERS"
echo "==================================="

# Stop services
pkill -f "java" || true
sleep 3

echo ""
echo "📝 CREATING USER SERVICE TEST CONTROLLER..."

# Create a simple test controller for User Service
cat > ~/dev-setup/social-platform-backend/user-service/src/main/java/com/socialplatform/backend/userservice/controller/TestController.java << 'EOF'
package com.socialplatform.backend.userservice.controller;

import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/test")
public class TestController {

    @GetMapping("/hello")
    public String hello() {
        return "Hello from User Service!";
    }

    @PostMapping("/register")
    public String register(@RequestBody String request) {
        return "User registration endpoint - Request: " + request;
    }

    @PostMapping("/login") 
    public String login(@RequestBody String request) {
        return "User login endpoint - Request: " + request;
    }
}
EOF

echo ""
echo "📝 CREATING POST SERVICE TEST CONTROLLER..."

# Create a simple test controller for Post Service
cat > ~/dev-setup/social-platform-backend/post-service/src/main/java/com/socialplatform/backend/postservice/controller/TestController.java << 'EOF'
package com.socialplatform.backend.postservice.controller;

import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/test")
public class TestController {

    @GetMapping("/hello")
    public String hello() {
        return "Hello from Post Service!";
    }

    @PostMapping("/posts")
    public String createPost(@RequestBody String request) {
        return "Post creation endpoint - Request: " + request;
    }

    @GetMapping("/posts")
    public String getPosts() {
        return "Get posts endpoint";
    }
}
EOF

echo ""
echo "🚀 REBUILDING WITH TEST CONTROLLERS..."

cd ~/dev-setup/social-platform-backend
mvn clean package -DskipTests

echo ""
echo "🔄 STARTING SERVICES WITH TEST ENDPOINTS..."

# Start User Service
cd user-service
java -jar target/user-service-0.0.1-SNAPSHOT.jar &
USER_PID=$!
echo "User Service: $USER_PID"

sleep 5

# Start Post Service  
cd ../post-service
java -jar target/post-service-0.0.1-SNAPSHOT.jar &
POST_PID=$!
echo "Post Service: $POST_PID"

sleep 5

# Kill any existing gateway and start new
fuser -k 8082/tcp || true
cd ../gateway-service
java -jar target/gateway-service-0.0.1-SNAPSHOT.jar &
GATEWAY_PID=$!
echo "Gateway Service: $GATEWAY_PID"

echo ""
echo "⏳ Waiting for services..."
sleep 15

echo ""
echo "🎉 TEST CONTROLLERS CREATED!"
echo "Test endpoints available at:"
echo "  User Service: http://localhost:8081/api/test/hello"
echo "  Post Service: http://localhost:8083/api/test/hello"
echo "  Gateway:      http://localhost:8082/api/test/hello"