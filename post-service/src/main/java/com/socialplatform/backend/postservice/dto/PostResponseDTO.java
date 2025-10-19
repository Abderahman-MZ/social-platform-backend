package com.socialplatform.backend.postservice.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class PostResponseDTO {
    private Long id;
    private Long userId;
    private String username;
    private String title;
    private String content;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}