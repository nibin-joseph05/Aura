package com.backend.aura.modules.sos.controller;

import com.backend.aura.modules.sos.dto.*;
import com.backend.aura.modules.sos.service.LiveLocationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/user/sos/live")
@RequiredArgsConstructor
public class LiveLocationController {

    private final LiveLocationService liveLocationService;

    @PostMapping("/start")
    public ResponseEntity<LiveLocationSessionResponse> startSession(
            @RequestHeader("X-User-Id") String userId,
            @RequestBody StartLiveLocationRequest request) {
        return ResponseEntity.ok(liveLocationService.startSession(userId, request));
    }

    @PostMapping("/stop")
    public ResponseEntity<LiveLocationSessionResponse> stopSession(
            @RequestHeader("X-User-Id") String userId) {
        return ResponseEntity.ok(liveLocationService.stopSession(userId));
    }

    @PostMapping("/{sessionId}/location")
    public ResponseEntity<Map<String, String>> updateLocation(
            @RequestHeader("X-User-Id") String userId,
            @PathVariable UUID sessionId,
            @RequestBody LiveLocationUpdateRequest request) {
        liveLocationService.addLocationPoint(userId, sessionId, request);
        return ResponseEntity.ok(Map.of("status", "ok"));
    }

    @GetMapping("/{sessionId}")
    public ResponseEntity<LiveLocationSessionResponse> getSession(
            @PathVariable UUID sessionId) {
        return ResponseEntity.ok(liveLocationService.getSession(sessionId));
    }

    @GetMapping("/active")
    public ResponseEntity<?> getActiveSession(
            @RequestHeader("X-User-Id") String userId) {
        return liveLocationService.getActiveSession(userId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.noContent().build());
    }
}
