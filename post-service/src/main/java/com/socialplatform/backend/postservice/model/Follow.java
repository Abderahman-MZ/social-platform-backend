package com.socialplatform.backend.postservice.model;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "follows")
public class Follow {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "follower_id", nullable = false)
    private Long followerId;

    @Column(name = "followed_id", nullable = false)
    private Long followedId;
}