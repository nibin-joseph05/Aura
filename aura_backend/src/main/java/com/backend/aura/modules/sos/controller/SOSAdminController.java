package com.backend.aura.modules.sos.controller;

import com.backend.aura.modules.common.dto.ApiResponse;
import com.backend.aura.modules.sos.dto.*;
import com.backend.aura.modules.sos.model.enums.SOSEventStatus;
import com.backend.aura.modules.sos.service.SOSService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/admin/sos")
@RequiredArgsConstructor
public class SOSAdminController {

    private final SOSService sosService;

    @GetMapping("/events")
    public ResponseEntity<ApiResponse<Page<SOSEventResponse>>> getAllEvents(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) SOSEventStatus status) {
        Pageable pageable = PageRequest.of(page, size);
        Page<SOSEventResponse> events;

        if (status != null) {
            events = sosService.getEventsByStatus(status, pageable);
        } else {
            events = sosService.getAllEvents(pageable);
        }

        return ResponseEntity.ok(ApiResponse.success(events));
    }

    @GetMapping("/events/{eventId}")
    public ResponseEntity<ApiResponse<SOSEventResponse>> getEventById(@PathVariable UUID eventId) {
        SOSEventResponse event = sosService.getEventById(eventId);
        return ResponseEntity.ok(ApiResponse.success(event));
    }

    @PutMapping("/events/{eventId}/acknowledge")
    public ResponseEntity<ApiResponse<SOSEventResponse>> acknowledgeEvent(@PathVariable UUID eventId) {
        SOSEventResponse event = sosService.acknowledgeEvent(eventId);
        return ResponseEntity.ok(ApiResponse.success(event));
    }

    @PutMapping("/events/{eventId}/resolve")
    public ResponseEntity<ApiResponse<SOSEventResponse>> resolveEvent(
            @PathVariable UUID eventId,
            @AuthenticationPrincipal String adminId,
            @RequestBody(required = false) ResolveSOSRequest request) {
        SOSEventResponse event = sosService.resolveEvent(eventId, adminId, request);
        return ResponseEntity.ok(ApiResponse.success(event));
    }

    @GetMapping("/stats")
    public ResponseEntity<ApiResponse<SOSStatsResponse>> getStats() {
        SOSStatsResponse stats = sosService.getStats();
        return ResponseEntity.ok(ApiResponse.success(stats));
    }
}
