package com.backend.aura.modules.sos.controller;

import com.backend.aura.modules.common.dto.ApiResponse;
import com.backend.aura.modules.sos.dto.*;
import com.backend.aura.modules.sos.service.SOSService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/user/sos")
@RequiredArgsConstructor
public class SOSController {

    private final SOSService sosService;

    @GetMapping
    public ResponseEntity<ApiResponse<SOSSettingsResponse>> getSOSSettings(
            @AuthenticationPrincipal String userId) {
        SOSSettingsResponse settings = sosService.getOrCreateSOSSettings(userId);
        return ResponseEntity.ok(ApiResponse.success(settings));
    }

    @PutMapping("/message")
    public ResponseEntity<ApiResponse<SOSSettingsResponse>> updateSOSMessage(
            @AuthenticationPrincipal String userId,
            @Valid @RequestBody UpdateSOSMessageRequest request) {
        SOSSettingsResponse settings = sosService.updateSOSMessage(userId, request.getCustomMessage());
        return ResponseEntity.ok(ApiResponse.success(settings));
    }

    @GetMapping("/contacts")
    public ResponseEntity<ApiResponse<List<TrustedContactResponse>>> getTrustedContacts(
            @AuthenticationPrincipal String userId) {
        List<TrustedContactResponse> contacts = sosService.getTrustedContacts(userId);
        return ResponseEntity.ok(ApiResponse.success(contacts));
    }

    @PostMapping("/contacts")
    public ResponseEntity<ApiResponse<TrustedContactResponse>> addTrustedContact(
            @AuthenticationPrincipal String userId,
            @Valid @RequestBody CreateTrustedContactRequest request) {
        TrustedContactResponse contact = sosService.addTrustedContact(userId, request);
        return ResponseEntity.ok(ApiResponse.success(contact));
    }

    @DeleteMapping("/contacts/{contactId}")
    public ResponseEntity<ApiResponse<Void>> removeTrustedContact(
            @AuthenticationPrincipal String userId,
            @PathVariable UUID contactId) {
        sosService.removeTrustedContact(userId, contactId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @PostMapping("/trigger")
    public ResponseEntity<ApiResponse<SOSEventResponse>> triggerSOS(
            @AuthenticationPrincipal String userId,
            @Valid @RequestBody TriggerSOSRequest request) {
        SOSEventResponse event = sosService.triggerSOS(userId, request);
        return ResponseEntity.ok(ApiResponse.success(event));
    }

    @GetMapping("/events")
    public ResponseEntity<ApiResponse<List<SOSEventResponse>>> getUserEvents(
            @AuthenticationPrincipal String userId) {
        List<SOSEventResponse> events = sosService.getUserEvents(userId);
        return ResponseEntity.ok(ApiResponse.success(events));
    }
}
