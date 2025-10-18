package com.socialplatform.backend.userservice.service;

import com.socialplatform.backend.userservice.dto.UserProfileDTO;
import com.socialplatform.backend.userservice.dto.UserProfileResponseDTO;
import com.socialplatform.backend.userservice.model.User;
import com.socialplatform.backend.userservice.model.UserProfile;
import com.socialplatform.backend.userservice.repository.UserProfileRepository;
import com.socialplatform.backend.userservice.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserProfileService {
    
    @Autowired
    private UserProfileRepository userProfileRepository;

    @Autowired
    private UserRepository userRepository;

    @Transactional
    public UserProfileResponseDTO createProfile(Long userId, UserProfileDTO profileDTO) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        
        // Check if profile already exists
        UserProfile existingProfile = userProfileRepository.findByUserId(userId);
        if (existingProfile != null) {
            throw new IllegalArgumentException("Profile already exists for this user");
        }
        
        UserProfile profile = new UserProfile();
        profile.setUser(user);
        profile.setBio(profileDTO.getBio());
        profile.setProfilePictureUrl(profileDTO.getProfilePictureUrl());
        profile.setLocation(profileDTO.getLocation());
        
        UserProfile savedProfile = userProfileRepository.save(profile);
        return convertToDTO(savedProfile); // ⭐ RETURN DTO INSTEAD OF ENTITY
    }

    public UserProfileResponseDTO getProfile(Long userId) {
        UserProfile profile = userProfileRepository.findByUserId(userId);
        if (profile == null) {
            throw new IllegalArgumentException("Profile not found for user id: " + userId);
        }
        return convertToDTO(profile); // ⭐ RETURN DTO INSTEAD OF ENTITY
    }

    @Transactional
    public UserProfileResponseDTO updateProfile(Long userId, UserProfileDTO profileDTO) {
        UserProfile profile = userProfileRepository.findByUserId(userId);
        if (profile == null) {
            throw new IllegalArgumentException("Profile not found for user id: " + userId);
        }
        
        if (profileDTO.getBio() != null) {
            profile.setBio(profileDTO.getBio());
        }
        if (profileDTO.getProfilePictureUrl() != null) {
            profile.setProfilePictureUrl(profileDTO.getProfilePictureUrl());
        }
        if (profileDTO.getLocation() != null) {
            profile.setLocation(profileDTO.getLocation());
        }
        
        UserProfile updatedProfile = userProfileRepository.save(profile);
        return convertToDTO(updatedProfile); // ⭐ RETURN DTO INSTEAD OF ENTITY
    }

    @Transactional
    public void deleteProfile(Long userId) {
        UserProfile profile = userProfileRepository.findByUserId(userId);
        if (profile != null) {
            userProfileRepository.delete(profile);
        }
    }

    // ⭐ NEW: Helper method to convert entity to DTO
    private UserProfileResponseDTO convertToDTO(UserProfile profile) {
        return new UserProfileResponseDTO(
            profile.getId(),
            profile.getBio(),
            profile.getProfilePictureUrl(),
            profile.getLocation(),
            profile.getUser().getId(),
            profile.getUser().getUsername()
        );
    }
}