package com.socialplatform.backend.userservice.controller;

import com.socialplatform.backend.userservice.dto.UserRegistrationRequest;
import com.socialplatform.backend.userservice.dto.UserResponse;
import com.socialplatform.backend.userservice.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/simple")
public class SimpleAuthController {
    
    @Autowired
    private UserService userService;

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody UserRegistrationRequest request) {
        try {
            UserResponse userResponse = userService.registerUser(request);
            return ResponseEntity.ok(userResponse);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Registration failed: " + e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }

    @GetMapping("/test-db")
    public String testDb() {
        return "Database connection is working!";
    }
}
