package com.socialplatform.backend.userservice.service;

import com.socialplatform.backend.userservice.entity.User;
import com.socialplatform.backend.userservice.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class UserService {
    
    @Autowired
    private UserRepository userRepository;
    
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }
    
    public Optional<User> getUserById(Long id) {
        return userRepository.findById(id);
    }
    
    public Optional<User> getUserByUsername(String username) {
        return userRepository.findByUsername(username);
    }
    
    public User createUser(String username, String email, String password, String firstName, String lastName) {
        User user = new User();
        user.setUsername(username);
        user.setEmail(email);
        user.setPasswordHash(password); // Simple password for now
        user.setFirstName(firstName);
        user.setLastName(lastName);
        
        return userRepository.save(user);
    }
}
