package com.socialplatform.backend.userservice.dto;

public class UserProfileResponseDTO {
    private Long id;
    private String bio;
    private String profilePictureUrl;
    private String location;
    private Long userId;
    private String username;

    // Default constructor
    public UserProfileResponseDTO() {}

    // Full constructor
    public UserProfileResponseDTO(Long id, String bio, String profilePictureUrl, 
                                 String location, Long userId, String username) {
        this.id = id;
        this.bio = bio;
        this.profilePictureUrl = profilePictureUrl;
        this.location = location;
        this.userId = userId;
        this.username = username;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getBio() { return bio; }
    public void setBio(String bio) { this.bio = bio; }

    public String getProfilePictureUrl() { return profilePictureUrl; }
    public void setProfilePictureUrl(String profilePictureUrl) { this.profilePictureUrl = profilePictureUrl; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
}