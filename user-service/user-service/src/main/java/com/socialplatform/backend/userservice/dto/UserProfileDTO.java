package com.socialplatform.backend.userservice.dto;

import jakarta.validation.constraints.Size;

public class UserProfileDTO {
    @Size(max = 500, message = "Bio must be less than 500 characters")
    private String bio;

    @Size(max = 255, message = "Profile picture URL must be less than 255 characters")
    private String profilePictureUrl;

    @Size(max = 100, message = "Location must be less than 100 characters")
    private String location;

    // Constructors
    public UserProfileDTO() {}

    public UserProfileDTO(String bio, String profilePictureUrl, String location) {
        this.bio = bio;
        this.profilePictureUrl = profilePictureUrl;
        this.location = location;
    }

    // Getters and Setters
    public String getBio() { return bio; }
    public void setBio(String bio) { this.bio = bio; }

    public String getProfilePictureUrl() { return profilePictureUrl; }
    public void setProfilePictureUrl(String profilePictureUrl) { this.profilePictureUrl = profilePictureUrl; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
}