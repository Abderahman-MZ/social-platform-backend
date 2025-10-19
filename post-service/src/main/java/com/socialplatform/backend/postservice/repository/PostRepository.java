package com.socialplatform.backend.postservice.repository;

import com.socialplatform.backend.postservice.model.Post;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

public interface PostRepository extends JpaRepository<Post, Long> {
    List<Post> findByUserId(Long userId);

    @Query("SELECT p FROM Post p WHERE p.userId IN :userIds ORDER BY p.createdAt DESC")
    List<Post> findByUserIds(@Param("userIds") List<Long> userIds);
}