package com.socialplatform.backend.userservice.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;

@Entity
@Table(name = "user_profiles")
public class UserProfile {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @JsonIgnore // ⭐ CRITICAL FIX: Prevent circular reference
    private User user;

    @Column(length = 500)
    private String bio;

    @Column(name = "profile_picture_url")
    private String profilePictureUrl;

    private String location;

    // Constructors
    public UserProfile() {}

    public UserProfile(User user, String bio, String profilePictureUrl, String location) {
        this.user = user;
        this.bio = bio;
        this.profilePictureUrl = profilePictureUrl;
        this.location = location;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
    public String getBio() { return bio; }
    public void setBio(String bio) { this.bio = bio; }
    public String getProfilePictureUrl() { return profilePictureUrl; }
    public void setProfilePictureUrl(String profilePictureUrl) { this.profilePictureUrl = profilePictureUrl; }
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    // ⭐ NEW: Helper method to get user ID without exposing entire user object
    @JsonProperty("userId")
    public Long getUserId() {
        return user != null ? user.getId() : null;
    }

    // ⭐ NEW: Helper method to get username without exposing entire user object
    @JsonProperty("username")
    public String getUsername() {
        return user != null ? user.getUsername() : null;
    }
}