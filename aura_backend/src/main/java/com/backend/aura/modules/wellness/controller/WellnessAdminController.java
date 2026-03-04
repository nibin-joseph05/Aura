package com.backend.aura.modules.wellness.controller;

import com.backend.aura.modules.common.dto.ApiResponse;
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

import java.util.Map;

@RestController
@RequestMapping("/api/admin/wellness")
@RequiredArgsConstructor
public class WellnessAdminController {
    private final WellnessService wellnessService;

    @GetMapping("/all")
    public ResponseEntity<ApiResponse<Page<WellnessUpdateResponse>>> getAllUpdates(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String userId,
            @RequestParam(required = false) WellnessCategory category) {
        Page<WellnessUpdateResponse> updates = wellnessService.getAllUpdates(userId, category,
                PageRequest.of(page, size));
        return ResponseEntity.ok(ApiResponse.success(updates));
    }

    @GetMapping("/stats")
    public ResponseEntity<ApiResponse<WellnessStatsResponse>> getStats() {
        WellnessStatsResponse stats = wellnessService.getStats();
        return ResponseEntity.ok(ApiResponse.success(stats));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteUpdate(@PathVariable String id) {
        wellnessService.adminDeleteUpdate(id);
        return ResponseEntity.ok(ApiResponse.success(null, "Post deleted"));
    }

    @PutMapping("/{id}/hide")
    public ResponseEntity<ApiResponse<Void>> hideUpdate(@PathVariable String id) {
        wellnessService.adminHideUpdate(id);
        return ResponseEntity.ok(ApiResponse.success(null, "Post hidden"));
    }

    @PostMapping("/{id}/warn")
    public ResponseEntity<ApiResponse<Void>> warnUser(
            @AuthenticationPrincipal String adminId,
            @PathVariable String id,
            @RequestBody(required = false) Map<String, String> body) {
        String message = body != null ? body.get("message") : null;
        wellnessService.warnUser(id, adminId, message);
        return ResponseEntity.ok(ApiResponse.success(null, "Warning sent to user"));
    }
}
