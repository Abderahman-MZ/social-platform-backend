package com.socialplatform.backend.postservice.repository;

import com.socialplatform.backend.postservice.model.Follow;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

public interface FollowRepository extends JpaRepository<Follow, Long> {
    @Query("SELECT f.followedId FROM Follow f WHERE f.followerId = :followerId")
    List<Long> findFollowedIdsByFollowerId(@Param("followerId") Long followerId);
    
    boolean existsByFollowerIdAndFollowedId(Long followerId, Long followedId);
    
    void deleteByFollowerIdAndFollowedId(Long followerId, Long followedId);
}