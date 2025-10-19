package com.socialplatform.backend.userservice.controller;

import com.socialplatform.backend.userservice.dto.UserRegistrationRequest;
import com.socialplatform.backend.userservice.dto.UserLoginRequest;
import com.socialplatform.backend.userservice.dto.UserResponse;
import com.socialplatform.backend.userservice.dto.LoginResponse;
import com.socialplatform.backend.userservice.model.User;
import com.socialplatform.backend.userservice.service.JwtService;
import com.socialplatform.backend.userservice.service.UserService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map; // ✅ ADD THIS IMPORT

@RestController
@RequestMapping("/user")
public class UserController {
    private static final Logger logger = LoggerFactory.getLogger(UserController.class);

    @Autowired
    private UserService userService;

    @Autowired
    private JwtService jwtService;

    @GetMapping("/public")
    public ResponseEntity<?> publicEndpoint() {
        return ResponseEntity.ok().body(
            Map.of("message", "This is a public endpoint - no authentication required", 
                   "status", "PUBLIC") // ✅ NOW Map IS IMPORTED
        );
    }

    @PostMapping("/register")
    public ResponseEntity<UserResponse> register(@Valid @RequestBody UserRegistrationRequest request) {
        logger.info("Processing registration for username: {}", request.getUsername());
        UserResponse userResponse = userService.registerUser(request);
        return new ResponseEntity<>(userResponse, HttpStatus.CREATED);
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody UserLoginRequest request) {
        logger.info("Processing login for username: {}", request.getUsername());
        User user = userService.findByUsername(request.getUsername());
        if (user == null || !userService.checkPassword(request.getPassword(), user.getPasswordHash())) {
            logger.warn("Login failed for username: {}", request.getUsername());
            throw new IllegalArgumentException("Invalid username or password");
        }
        String token = jwtService.generateToken(user.getId(), user.getUsername()); // ✅ FIXED METHOD CALL
        return new ResponseEntity<>(new LoginResponse(token, "Login successful"), HttpStatus.OK); // ✅ FIXED CONSTRUCTOR
    }

    @GetMapping("/username/{userId}")
    public ResponseEntity<String> getUsernameById(@PathVariable Long userId) {
        User user = userService.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return ResponseEntity.ok(user.getUsername());
    }

    @GetMapping("/exists/{userId}")
    public ResponseEntity<Boolean> userExists(@PathVariable Long userId) {
        boolean exists = userService.findById(userId).isPresent();
        return ResponseEntity.ok(exists);
    }
}