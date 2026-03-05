package com.backend.aura.modules.wellness.controller;

import com.backend.aura.modules.common.dto.ApiResponse;
import com.backend.aura.modules.wellness.dto.CommentDTO;
import com.backend.aura.modules.wellness.dto.CreateCommentRequest;
import com.backend.aura.modules.wellness.service.WellnessCommentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/wellness")
@RequiredArgsConstructor
public class WellnessCommentController {
    private final WellnessCommentService commentService;

    @PostMapping("/{postId}/comments")
    public ResponseEntity<ApiResponse<CommentDTO>> createComment(
            @AuthenticationPrincipal String userId,
            @PathVariable String postId,
            @Valid @RequestBody CreateCommentRequest request) {
        CommentDTO comment = commentService.createComment(userId, postId, request);
        return ResponseEntity.ok(ApiResponse.success(comment, "Comment added"));
    }

    @GetMapping("/{postId}/comments")
    public ResponseEntity<ApiResponse<List<CommentDTO>>> getComments(@PathVariable String postId) {
        List<CommentDTO> comments = commentService.getComments(postId);
        return ResponseEntity.ok(ApiResponse.success(comments));
    }

    @GetMapping("/{postId}/comments/paged")
    public ResponseEntity<ApiResponse<Page<CommentDTO>>> getCommentsPaged(
            @PathVariable String postId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Page<CommentDTO> comments = commentService.getCommentsPaged(postId, PageRequest.of(page, size));
        return ResponseEntity.ok(ApiResponse.success(comments));
    }

    @DeleteMapping("/comments/{commentId}")
    public ResponseEntity<ApiResponse<Void>> deleteComment(
            @AuthenticationPrincipal String userId,
            @PathVariable String commentId) {
        commentService.deleteComment(commentId, userId);
        return ResponseEntity.ok(ApiResponse.success(null, "Comment deleted"));
    }

    @PostMapping("/comments/{commentId}/translate")
    public ResponseEntity<ApiResponse<CommentDTO>> translateComment(@PathVariable String commentId) {
        CommentDTO comment = commentService.translateComment(commentId);
        return ResponseEntity.ok(ApiResponse.success(comment));
    }
}
