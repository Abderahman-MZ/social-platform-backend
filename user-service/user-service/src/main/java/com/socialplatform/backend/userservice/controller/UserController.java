package com.socialplatform.backend.userservice.controller;

import com.socialplatform.backend.userservice.dto.UserRegistrationRequest;
import com.socialplatform.backend.userservice.dto.UserLoginRequest;
import com.socialplatform.backend.userservice.dto.UserResponse;
import com.socialplatform.backend.userservice.dto.LoginResponse;
import com.socialplatform.backend.userservice.dto.UserProfileDTO;
import com.socialplatform.backend.userservice.model.User;
import com.socialplatform.backend.userservice.model.UserProfile;
import com.socialplatform.backend.userservice.service.JwtService;
import com.socialplatform.backend.userservice.service.UserService;
import com.socialplatform.backend.userservice.service.UserProfileService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/user")
public class UserController {
    private static final Logger logger = LoggerFactory.getLogger(UserController.class);

    @Autowired
    private UserService userService;

    @Autowired
    private JwtService jwtService;

    @Autowired
    private UserProfileService userProfileService;

    @PostMapping("/register")
    public ResponseEntity<UserResponse> register(@Valid @RequestBody UserRegistrationRequest request) {
        logger.info("Processing registration for username: {}", request.getUsername());
        UserResponse userResponse = userService.registerUser(request);
        return new ResponseEntity<>(userResponse, HttpStatus.CREATED);
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody UserLoginRequest request) {
        logger.info("Processing login for username: {}", request.getUsername());
        User user = userService.findByUsername(request.getUsername());
        if (user == null || !userService.checkPassword(request.getPassword(), user.getPasswordHash())) {
            logger.warn("Login failed for username: {}", request.getUsername());
            throw new IllegalArgumentException("Invalid username or password");
        }
        String token = jwtService.generateToken(request.getUsername());
        return new ResponseEntity<>(new LoginResponse(token), HttpStatus.OK);
    }

    @GetMapping("/public")
    public ResponseEntity<String> publicEndpoint() {
        return ResponseEntity.ok("This is a public endpoint");
    }

    // Profile Management Endpoints
    @PostMapping("/profile")
    public ResponseEntity<UserProfile> createProfile(@Valid @RequestBody UserProfileDTO profileDTO,
                                                   @RequestHeader("Authorization") String authHeader) {
        String token = authHeader.replace("Bearer ", "");
        String username = jwtService.extractUsername(token);
        User user = userService.findByUsername(username);
        
        UserProfile profile = userProfileService.createProfile(user.getId(), profileDTO);
        return new ResponseEntity<>(profile, HttpStatus.CREATED);
    }

    @GetMapping("/profile")
    public ResponseEntity<UserProfile> getProfile(@RequestHeader("Authorization") String authHeader) {
        String token = authHeader.replace("Bearer ", "");
        String username = jwtService.extractUsername(token);
        User user = userService.findByUsername(username);
        
        UserProfile profile = userProfileService.getProfile(user.getId());
        return new ResponseEntity<>(profile, HttpStatus.OK);
    }

    @PutMapping("/profile")
    public ResponseEntity<UserProfile> updateProfile(@Valid @RequestBody UserProfileDTO profileDTO,
                                                    @RequestHeader("Authorization") String authHeader) {
        String token = authHeader.replace("Bearer ", "");
        String username = jwtService.extractUsername(token);
        User user = userService.findByUsername(username);
        
        UserProfile profile = userProfileService.updateProfile(user.getId(), profileDTO);
        return new ResponseEntity<>(profile, HttpStatus.OK);
    }

    @DeleteMapping("/profile")
    public ResponseEntity<Void> deleteProfile(@RequestHeader("Authorization") String authHeader) {
        String token = authHeader.replace("Bearer ", "");
        String username = jwtService.extractUsername(token);
        User user = userService.findByUsername(username);
        
        userProfileService.deleteProfile(user.getId());
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
}