package com.backend.aura.modules.wellness.controller;

import com.backend.aura.modules.common.dto.ApiResponse;
import com.backend.aura.modules.common.upload.service.FileUploadService;
import com.backend.aura.modules.wellness.dto.CreateWellnessUpdateRequest;
import com.backend.aura.modules.wellness.dto.EditWellnessUpdateRequest;
import com.backend.aura.modules.wellness.dto.WellnessUpdateResponse;
import com.backend.aura.modules.wellness.model.enums.WellnessCategory;
import com.backend.aura.modules.wellness.service.WellnessService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/user/wellness")
@RequiredArgsConstructor
public class WellnessController {
    private final WellnessService wellnessService;
    private final FileUploadService fileUploadService;

    @GetMapping("/feed")
    public ResponseEntity<ApiResponse<Page<WellnessUpdateResponse>>> getFeed(
            @AuthenticationPrincipal String userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) WellnessCategory category) {
        Page<WellnessUpdateResponse> feed = wellnessService.getFeed(userId, category, PageRequest.of(page, size));
        return ResponseEntity.ok(ApiResponse.success(feed));
    }

    @GetMapping("/my-updates")
    public ResponseEntity<ApiResponse<Page<WellnessUpdateResponse>>> getMyUpdates(
            @AuthenticationPrincipal String userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Page<WellnessUpdateResponse> updates = wellnessService.getMyUpdates(userId, PageRequest.of(page, size));
        return ResponseEntity.ok(ApiResponse.success(updates));
    }

    @GetMapping("/user/{userId}/posts")
    public ResponseEntity<ApiResponse<Page<WellnessUpdateResponse>>> getUserPosts(
            @PathVariable String userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Page<WellnessUpdateResponse> posts = wellnessService.getUserPosts(userId, PageRequest.of(page, size));
        return ResponseEntity.ok(ApiResponse.success(posts));
    }

    @GetMapping("/trending")
    public ResponseEntity<ApiResponse<List<WellnessUpdateResponse>>> getTrending() {
        List<WellnessUpdateResponse> trending = wellnessService.getTrendingUpdates();
        return ResponseEntity.ok(ApiResponse.success(trending));
    }

    @PostMapping("/updates")
    public ResponseEntity<ApiResponse<WellnessUpdateResponse>> createUpdate(
            @AuthenticationPrincipal String userId,
            @Valid @RequestBody CreateWellnessUpdateRequest request) {
        WellnessUpdateResponse response = wellnessService.createUpdate(userId, request);
        return ResponseEntity.ok(ApiResponse.success(response, "Posted successfully"));
    }

    @PutMapping("/updates/{id}")
    public ResponseEntity<ApiResponse<WellnessUpdateResponse>> editUpdate(
            @AuthenticationPrincipal String userId,
            @PathVariable String id,
            @Valid @RequestBody EditWellnessUpdateRequest request) {
        WellnessUpdateResponse response = wellnessService.editUpdate(userId, id, request);
        return ResponseEntity.ok(ApiResponse.success(response, "Post updated"));
    }

    @DeleteMapping("/updates/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteUpdate(
            @AuthenticationPrincipal String userId,
            @PathVariable String id) {
        wellnessService.deleteUpdate(userId, id);
        return ResponseEntity.ok(ApiResponse.success(null, "Post deleted"));
    }

    @PostMapping("/updates/upload-image")
    public ResponseEntity<?> uploadPostImage(
            @AuthenticationPrincipal String userId,
            @RequestParam("file") MultipartFile file) {
        try {
            if (file.isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("error", "File is empty"));
            }
            String contentType = file.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                return ResponseEntity.badRequest().body(Map.of("error", "Only image files are allowed"));
            }
            if (file.getSize() > 10 * 1024 * 1024) {
                return ResponseEntity.badRequest().body(Map.of("error", "File size exceeds 10MB limit"));
            }
            String imageUrl = fileUploadService.uploadWellnessImage(file, userId);
            return ResponseEntity.ok(Map.of("url", imageUrl, "success", true));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("error", "Failed to upload image"));
        }
    }

    @PostMapping("/updates/{id}/like")
    public ResponseEntity<ApiResponse<WellnessUpdateResponse>> likeUpdate(
            @AuthenticationPrincipal String userId,
            @PathVariable String id) {
        WellnessUpdateResponse response = wellnessService.likeUpdate(userId, id);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @DeleteMapping("/updates/{id}/like")
    public ResponseEntity<ApiResponse<WellnessUpdateResponse>> unlikeUpdate(
            @AuthenticationPrincipal String userId,
            @PathVariable String id) {
        WellnessUpdateResponse response = wellnessService.unlikeUpdate(userId, id);
        return ResponseEntity.ok(ApiResponse.success(response));
    }
}
