package com.socialplatform.backend.userservice.controller;

import com.socialplatform.backend.userservice.model.User;
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
    public ResponseEntity<?> register(@RequestBody User user) {
        try {
            User savedUser = userService.saveUser(user);
            // Clear password hash from response
            savedUser.setPasswordHash(null);
            return ResponseEntity.ok(savedUser);
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