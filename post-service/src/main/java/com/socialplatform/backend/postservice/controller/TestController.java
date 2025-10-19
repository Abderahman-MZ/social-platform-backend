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
