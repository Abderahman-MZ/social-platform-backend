package com.socialplatform.backend.postservice.service;

import com.socialplatform.backend.postservice.dto.PostDTO;
import com.socialplatform.backend.postservice.dto.PostResponseDTO;
import com.socialplatform.backend.postservice.model.Follow;
import com.socialplatform.backend.postservice.model.Post;
import com.socialplatform.backend.postservice.repository.FollowRepository;
import com.socialplatform.backend.postservice.repository.PostRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class PostService {
    @Autowired
    private PostRepository postRepository;

    @Autowired
    private FollowRepository followRepository;

    @Autowired
    private UserServiceClient userServiceClient;

    @Transactional
    public PostResponseDTO createPost(Long userId, PostDTO postDTO) {
        Post post = new Post();
        post.setUserId(userId);
        post.setTitle(postDTO.getTitle());
        post.setContent(postDTO.getContent());
        Post savedPost = postRepository.save(post);
        
        String username = userServiceClient.getUsernameById(userId);
        return convertToDTO(savedPost, username);
    }

    public PostResponseDTO getPost(Long postId) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new RuntimeException("Post not found"));
        String username = userServiceClient.getUsernameById(post.getUserId());
        return convertToDTO(post, username);
    }

    public List<PostResponseDTO> getPostsByUserId(Long userId) {
        String username = userServiceClient.getUsernameById(userId);
        return postRepository.findByUserId(userId).stream()
                .map(post -> convertToDTO(post, username))
                .collect(Collectors.toList());
    }

    @Transactional
    public PostResponseDTO updatePost(Long postId, PostDTO postDTO, Long userId) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new RuntimeException("Post not found"));
        
        if (!post.getUserId().equals(userId)) {
            throw new RuntimeException("User not authorized to update this post");
        }
        
        post.setTitle(postDTO.getTitle());
        post.setContent(postDTO.getContent());
        Post updatedPost = postRepository.save(post);
        String username = userServiceClient.getUsernameById(userId);
        return convertToDTO(updatedPost, username);
    }

    @Transactional
    public void deletePost(Long postId, Long userId) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new RuntimeException("Post not found"));
        
        if (!post.getUserId().equals(userId)) {
            throw new RuntimeException("User not authorized to delete this post");
        }
        
        postRepository.delete(post);
    }

    public List<PostResponseDTO> getUserFeed(Long userId) {
        // Feed algorithm: Get posts from user and their followed users
        List<Long> followedIds = followRepository.findFollowedIdsByFollowerId(userId);
        followedIds.add(userId); // Include user's own posts
        
        List<Post> posts = postRepository.findByUserIds(followedIds);
        
        return posts.stream()
                .map(post -> {
                    String username = userServiceClient.getUsernameById(post.getUserId());
                    return convertToDTO(post, username);
                })
                .collect(Collectors.toList());
    }

    @Transactional
    public void followUser(Long followerId, Long followedId) {
        if (followerId.equals(followedId)) {
            throw new RuntimeException("Cannot follow yourself");
        }
        
        Boolean userExists = userServiceClient.userExists(followedId);
        if (userExists == null || !userExists) {
            throw new RuntimeException("Followed user does not exist");
        }
        
        if (followRepository.existsByFollowerIdAndFollowedId(followerId, followedId)) {
            throw new RuntimeException("Already following this user");
        }
        
        Follow follow = new Follow();
        follow.setFollowerId(followerId);
        follow.setFollowedId(followedId);
        followRepository.save(follow);
    }

    @Transactional
    public void unfollowUser(Long followerId, Long followedId) {
        if (!followRepository.existsByFollowerIdAndFollowedId(followerId, followedId)) {
            throw new RuntimeException("Not following this user");
        }
        followRepository.deleteByFollowerIdAndFollowedId(followerId, followedId);
    }

    private PostResponseDTO convertToDTO(Post post, String username) {
        PostResponseDTO dto = new PostResponseDTO();
        dto.setId(post.getId());
        dto.setUserId(post.getUserId());
        dto.setUsername(username);
        dto.setTitle(post.getTitle());
        dto.setContent(post.getContent());
        dto.setCreatedAt(post.getCreatedAt());
        dto.setUpdatedAt(post.getUpdatedAt());
        return dto;
    }
}