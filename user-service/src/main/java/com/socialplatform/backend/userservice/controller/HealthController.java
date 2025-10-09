package com.socialplatform.backend.userservice.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthController {

    @GetMapping("/health")
    public String health() {
        return "User Service is running!";
    }

    @GetMapping("/")
    public String home() {
        return "Welcome to User Service";
    }
}
