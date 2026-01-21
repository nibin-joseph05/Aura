package com.backend.aura.modules.wellness.controller;

import com.backend.aura.modules.common.dto.ApiResponse;
import com.backend.aura.modules.wellness.dto.ModerateWellnessRequest;
import com.backend.aura.modules.wellness.dto.WellnessStatsResponse;
import com.backend.aura.modules.wellness.dto.WellnessUpdateResponse;
import com.backend.aura.modules.wellness.model.enums.WellnessCategory;
import com.backend.aura.modules.wellness.service.WellnessService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/wellness")
@RequiredArgsConstructor
public class WellnessAdminController {
    private final WellnessService wellnessService;

    @GetMapping("/pending")
    public ResponseEntity<ApiResponse<Page<WellnessUpdateResponse>>> getPendingUpdates(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Page<WellnessUpdateResponse> updates = wellnessService.getPendingUpdates(PageRequest.of(page, size));
        return ResponseEntity.ok(ApiResponse.success(updates));
    }

    @GetMapping("/all")
    public ResponseEntity<ApiResponse<Page<WellnessUpdateResponse>>> getAllUpdates(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) WellnessCategory category) {
        Page<WellnessUpdateResponse> updates = wellnessService.getAllUpdates(category, PageRequest.of(page, size));
        return ResponseEntity.ok(ApiResponse.success(updates));
    }

    @GetMapping("/stats")
    public ResponseEntity<ApiResponse<WellnessStatsResponse>> getStats() {
        WellnessStatsResponse stats = wellnessService.getStats();
        return ResponseEntity.ok(ApiResponse.success(stats));
    }

    @PutMapping("/{id}/approve")
    public ResponseEntity<ApiResponse<WellnessUpdateResponse>> approveUpdate(
            @AuthenticationPrincipal String adminId,
            @PathVariable String id) {
        WellnessUpdateResponse response = wellnessService.approveUpdate(id, adminId);
        return ResponseEntity.ok(ApiResponse.success(response, "Update approved"));
    }

    @PutMapping("/{id}/reject")
    public ResponseEntity<ApiResponse<WellnessUpdateResponse>> rejectUpdate(
            @AuthenticationPrincipal String adminId,
            @PathVariable String id,
            @RequestBody(required = false) ModerateWellnessRequest request) {
        String reason = request != null ? request.getRejectionReason() : null;
        WellnessUpdateResponse response = wellnessService.rejectUpdate(id, adminId, reason);
        return ResponseEntity.ok(ApiResponse.success(response, "Update rejected"));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteUpdate(@PathVariable String id) {
        wellnessService.adminDeleteUpdate(id);
        return ResponseEntity.ok(ApiResponse.success(null, "Update deleted"));
    }
}
