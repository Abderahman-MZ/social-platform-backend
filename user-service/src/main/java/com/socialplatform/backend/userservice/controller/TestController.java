package com.socialplatform.backend.userservice.controller;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/user")
public class TestController {
    
    @GetMapping("/public")
    public Map<String, String> publicEndpoint() {
        return Map.of(
            "message", "This is a public endpoint - no authentication required",
            "status", "PUBLIC"
        );
    }

    @GetMapping("/test")
    public Map<String, Object> protectedEndpoint(Authentication authentication) {
        String username = authentication.getName();
        String roles = authentication.getAuthorities().stream()
                .map(GrantedAuthority::getAuthority)
                .collect(Collectors.joining(", "));
                
        Map<String, Object> response = new HashMap<>();
        response.put("message", "User test endpoint - requires authentication");
        response.put("user", username);
        response.put("role", roles);
        response.put("status", "AUTHENTICATED");
        
        return response;
    }
}
