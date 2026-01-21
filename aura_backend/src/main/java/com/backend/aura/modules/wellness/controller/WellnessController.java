package com.backend.aura.modules.wellness.controller;

import com.backend.aura.modules.common.dto.ApiResponse;
import com.backend.aura.modules.wellness.dto.CreateWellnessUpdateRequest;
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

import java.util.List;

@RestController
@RequestMapping("/api/user/wellness")
@RequiredArgsConstructor
public class WellnessController {
    private final WellnessService wellnessService;

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
        return ResponseEntity.ok(ApiResponse.success(response, "Update created and pending approval"));
    }

    @DeleteMapping("/updates/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteUpdate(
            @AuthenticationPrincipal String userId,
            @PathVariable String id) {
        wellnessService.deleteUpdate(userId, id);
        return ResponseEntity.ok(ApiResponse.success(null, "Update deleted"));
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
