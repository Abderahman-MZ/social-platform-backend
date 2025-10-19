package com.socialplatform.backend.postservice.controller;

import com.socialplatform.backend.postservice.dto.PostDTO;
import com.socialplatform.backend.postservice.dto.PostResponseDTO;
import com.socialplatform.backend.postservice.service.JwtService;
import com.socialplatform.backend.postservice.service.PostService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/posts")
public class PostController {

    @Autowired
    private PostService postService;

    @Autowired
    private JwtService jwtService;

    @PostMapping
    public ResponseEntity<PostResponseDTO> createPost(
            @RequestHeader("Authorization") String authHeader,
            @Valid @RequestBody PostDTO postDTO) {
        String token = authHeader.replace("Bearer ", "");
        Long userId = jwtService.extractUserId(token);
        PostResponseDTO post = postService.createPost(userId, postDTO);
        return new ResponseEntity<>(post, HttpStatus.CREATED);
    }

    @GetMapping("/{postId}")
    public ResponseEntity<PostResponseDTO> getPost(@PathVariable Long postId) {
        PostResponseDTO post = postService.getPost(postId);
        return ResponseEntity.ok(post);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<PostResponseDTO>> getPostsByUserId(@PathVariable Long userId) {
        List<PostResponseDTO> posts = postService.getPostsByUserId(userId);
        return ResponseEntity.ok(posts);
    }

    @PutMapping("/{postId}")
    public ResponseEntity<PostResponseDTO> updatePost(
            @PathVariable Long postId,
            @RequestHeader("Authorization") String authHeader,
            @Valid @RequestBody PostDTO postDTO) {
        String token = authHeader.replace("Bearer ", "");
        Long userId = jwtService.extractUserId(token);
        PostResponseDTO post = postService.updatePost(postId, postDTO, userId);
        return ResponseEntity.ok(post);
    }

    @DeleteMapping("/{postId}")
    public ResponseEntity<Void> deletePost(
            @PathVariable Long postId,
            @RequestHeader("Authorization") String authHeader) {
        String token = authHeader.replace("Bearer ", "");
        Long userId = jwtService.extractUserId(token);
        postService.deletePost(postId, userId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/feed")
    public ResponseEntity<List<PostResponseDTO>> getUserFeed(
            @RequestHeader("Authorization") String authHeader) {
        String token = authHeader.replace("Bearer ", "");
        Long userId = jwtService.extractUserId(token);
        List<PostResponseDTO> feed = postService.getUserFeed(userId);
        return ResponseEntity.ok(feed);
    }

    @PostMapping("/follow/{followedId}")
    public ResponseEntity<Void> followUser(
            @RequestHeader("Authorization") String authHeader,
            @PathVariable Long followedId) {
        String token = authHeader.replace("Bearer ", "");
        Long followerId = jwtService.extractUserId(token);
        postService.followUser(followerId, followedId);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/follow/{followedId}")
    public ResponseEntity<Void> unfollowUser(
            @RequestHeader("Authorization") String authHeader,
            @PathVariable Long followedId) {
        String token = authHeader.replace("Bearer ", "");
        Long followerId = jwtService.extractUserId(token);
        postService.unfollowUser(followerId, followedId);
        return ResponseEntity.noContent().build();
    }
}