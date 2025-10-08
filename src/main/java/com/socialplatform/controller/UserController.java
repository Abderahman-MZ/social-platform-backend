package com.socialplatform.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class UserController {
    
    @GetMapping("/api/health")
    public String health() {
        return "Backend is running!";
    }
}
