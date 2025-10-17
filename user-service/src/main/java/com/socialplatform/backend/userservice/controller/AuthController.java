package com.socialplatform.backend.userservice.controller;

import com.socialplatform.backend.userservice.dto.UserRegistrationRequest;
import com.socialplatform.backend.userservice.dto.UserResponse;
import com.socialplatform.backend.userservice.model.User;
import com.socialplatform.backend.userservice.service.JwtService;
import com.socialplatform.backend.userservice.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
public class AuthController {
    @Autowired
    private UserService userService;
    @Autowired
    private JwtService jwtService;

    @PostMapping("/api/v1/register")
    public ResponseEntity<UserResponse> register(@RequestBody UserRegistrationRequest request) {
        UserResponse userResponse = userService.registerUser(request);
        return ResponseEntity.ok(userResponse);
    }

    @PostMapping("/api/v1/login")
    public ResponseEntity<Map<String, String>> login(@RequestBody Map<String, String> credentials) {
        String username = credentials.get("username");
        String password = credentials.get("password");
        User user = userService.findByUsername(username);
        if (user != null && userService.checkPassword(password, user.getPasswordHash())) {
            String token = jwtService.generateToken(username);
            return ResponseEntity.ok(Map.of("token", token));
        }
        return ResponseEntity.status(401).body(Map.of("error", "Invalid credentials"));
    }
}
