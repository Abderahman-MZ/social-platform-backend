package com.socialplatform.backend.userservice.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TestController {

    @GetMapping("/test")
    public String publicEndpoint() {
        return "Public test endpoint - accessible to all";
    }

    @GetMapping("/admin/test")
    public String adminEndpoint() {
        return "Admin test endpoint - requires ROLE_ADMIN";
    }

    @GetMapping("/user/test")
    public String userEndpoint() {
        return "User test endpoint - requires authentication";
    }
}