package com.socialplatform.backend.userservice.service;

import com.socialplatform.backend.userservice.dto.UserRegistrationRequest;
import com.socialplatform.backend.userservice.dto.UserResponse;
import com.socialplatform.backend.userservice.model.User;
import com.socialplatform.backend.userservice.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
@Transactional
public class UserService {
    private static final Logger logger = LoggerFactory.getLogger(UserService.class);

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    public UserResponse registerUser(UserRegistrationRequest request) {
        // Check for existing username
        if (userRepository.findByUsername(request.getUsername()).isPresent()) {
            logger.warn("Registration failed: Username {} already exists", request.getUsername());
            throw new IllegalArgumentException("Username already exists");
        }
        
        // Check for existing email
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            logger.warn("Registration failed: Email {} already exists", request.getEmail());
            throw new IllegalArgumentException("Email already exists");
        }

        // Create and save new user
        User user = new User();
        user.setUsername(request.getUsername());
        user.setEmail(request.getEmail());
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setRole("USER");

        User savedUser = userRepository.save(user);
        logger.info("User registered successfully: {}", savedUser.getUsername());

        return new UserResponse(savedUser.getId(), savedUser.getUsername(), 
                              savedUser.getEmail(), savedUser.getRole(), savedUser.getCreatedAt());
    }

    public User findByUsername(String username) {
        Optional<User> user = userRepository.findByUsername(username);
        return user.orElse(null);
    }

    public boolean checkPassword(String rawPassword, String encodedPassword) {
        boolean matches = passwordEncoder.matches(rawPassword, encodedPassword);
        logger.debug("Password check result: {}", matches ? "MATCH" : "NO MATCH");
        return matches;
    }

    public Optional<User> findById(Long userId) {
        return userRepository.findById(userId);
    }
}