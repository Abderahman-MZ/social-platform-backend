package com.socialplatform.backend.postservice.service;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "user-service", url = "http://localhost:8081")
public interface UserServiceClient {
    @GetMapping("/api/users/user/username/{userId}")
    String getUsernameById(@PathVariable("userId") Long userId);

    @GetMapping("/api/users/user/exists/{userId}")
    Boolean userExists(@PathVariable("userId") Long userId);
}