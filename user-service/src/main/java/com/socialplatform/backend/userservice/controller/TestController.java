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
