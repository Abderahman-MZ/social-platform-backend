package com.socialplatform.backend.userservice.repository;

import com.socialplatform.backend.userservice.model.UserProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface UserProfileRepository extends JpaRepository<UserProfile, Long> {
    
    @Query("SELECT up FROM UserProfile up WHERE up.user.id = :userId")
    UserProfile findByUserId(@Param("userId") Long userId);
}