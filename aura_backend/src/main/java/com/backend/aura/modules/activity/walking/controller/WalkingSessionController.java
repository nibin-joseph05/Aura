package com.backend.aura.modules.activity.walking.controller;

import com.backend.aura.modules.activity.walking.dto.RoutePointDTO;
import com.backend.aura.modules.activity.walking.dto.WalkingSessionDTO;
import com.backend.aura.modules.activity.walking.service.WalkingSessionService;
import com.backend.aura.modules.common.dto.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/user/walking")
@RequiredArgsConstructor
public class WalkingSessionController {

    private final WalkingSessionService walkingService;

    @PostMapping("/start")
    public ResponseEntity<ApiResponse<WalkingSessionDTO>> startSession(
            @AuthenticationPrincipal String userId) {
        WalkingSessionDTO session = walkingService.startSession(userId);
        return ResponseEntity.ok(ApiResponse.success(session, "Walking session started"));
    }

    @PutMapping("/{sessionId}/end")
    public ResponseEntity<ApiResponse<WalkingSessionDTO>> endSession(
            @AuthenticationPrincipal String userId,
            @PathVariable String sessionId,
            @RequestBody Map<String, Object> body) {
        double distanceMeters = ((Number) body.getOrDefault("distanceMeters", 0)).doubleValue();
        int stepsCount = ((Number) body.getOrDefault("stepsCount", 0)).intValue();
        WalkingSessionDTO session = walkingService.endSession(userId, sessionId, distanceMeters, stepsCount);
        return ResponseEntity.ok(ApiResponse.success(session, "Walking session ended"));
    }

    @PostMapping("/{sessionId}/route")
    public ResponseEntity<ApiResponse<WalkingSessionDTO>> addRoutePoints(
            @AuthenticationPrincipal String userId,
            @PathVariable String sessionId,
            @RequestBody List<RoutePointDTO> points) {
        WalkingSessionDTO session = walkingService.addRoutePoints(userId, sessionId, points);
        return ResponseEntity.ok(ApiResponse.success(session));
    }

    @GetMapping("/active")
    public ResponseEntity<ApiResponse<WalkingSessionDTO>> getActiveSession(
            @AuthenticationPrincipal String userId) {
        return walkingService.getActiveSession(userId)
                .map(session -> ResponseEntity.ok(ApiResponse.success(session)))
                .orElse(ResponseEntity.ok(ApiResponse.success(null, "No active session")));
    }

    @GetMapping("/history")
    public ResponseEntity<ApiResponse<Page<WalkingSessionDTO>>> getHistory(
            @AuthenticationPrincipal String userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Page<WalkingSessionDTO> history = walkingService.getHistory(userId, PageRequest.of(page, size));
        return ResponseEntity.ok(ApiResponse.success(history));
    }

    @GetMapping("/stats")
    public ResponseEntity<ApiResponse<WalkingSessionService.WalkingStatsDTO>> getStats(
            @AuthenticationPrincipal String userId) {
        WalkingSessionService.WalkingStatsDTO stats = walkingService.getStats(userId);
        return ResponseEntity.ok(ApiResponse.success(stats));
    }
}
