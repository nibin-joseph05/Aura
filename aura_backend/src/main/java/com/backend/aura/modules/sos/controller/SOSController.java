package com.backend.aura.modules.sos.controller;

import com.backend.aura.modules.common.dto.ApiResponse;
import com.backend.aura.modules.sos.dto.*;
import com.backend.aura.modules.sos.service.SOSService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/user/sos")
@RequiredArgsConstructor
public class SOSController {

    private static final Logger log = LoggerFactory.getLogger(SOSController.class);

    private final SOSService sosService;

    @GetMapping
    public ResponseEntity<ApiResponse<SOSSettingsResponse>> getSOSSettings(
            @AuthenticationPrincipal String userId) {
        log.debug("SOS_CTRL - GET /api/user/sos | userId: {}", userId);
        SOSSettingsResponse settings = sosService.getOrCreateSOSSettings(userId);
        log.debug("SOS_CTRL - GET /api/user/sos RESPONSE: 200 OK | userId: {}", userId);
        return ResponseEntity.ok(ApiResponse.success(settings));
    }

    @PutMapping("/message")
    public ResponseEntity<ApiResponse<SOSSettingsResponse>> updateSOSMessage(
            @AuthenticationPrincipal String userId,
            @Valid @RequestBody UpdateSOSMessageRequest request) {
        log.debug("SOS_CTRL - PUT /api/user/sos/message | userId: {} | message: {}", userId,
                request.getCustomMessage());
        SOSSettingsResponse settings = sosService.updateSOSMessage(userId, request.getCustomMessage());
        log.debug("SOS_CTRL - PUT /api/user/sos/message RESPONSE: 200 OK | userId: {}", userId);
        return ResponseEntity.ok(ApiResponse.success(settings));
    }

    @GetMapping("/contacts")
    public ResponseEntity<ApiResponse<List<TrustedContactResponse>>> getTrustedContacts(
            @AuthenticationPrincipal String userId) {
        log.debug("SOS_CTRL - GET /api/user/sos/contacts | userId: {}", userId);
        List<TrustedContactResponse> contacts = sosService.getTrustedContacts(userId);
        log.debug("SOS_CTRL - GET /api/user/sos/contacts RESPONSE: 200 OK | userId: {} | count: {}",
                userId, contacts.size());
        return ResponseEntity.ok(ApiResponse.success(contacts));
    }

    @PostMapping("/contacts")
    public ResponseEntity<ApiResponse<TrustedContactResponse>> addTrustedContact(
            @AuthenticationPrincipal String userId,
            @Valid @RequestBody CreateTrustedContactRequest request) {
        log.debug("SOS_CTRL - POST /api/user/sos/contacts | userId: {} | contactName: {}",
                userId, request.getName());
        TrustedContactResponse contact = sosService.addTrustedContact(userId, request);
        log.debug("SOS_CTRL - POST /api/user/sos/contacts RESPONSE: 200 OK | userId: {} | contactId: {}",
                userId, contact.getId());
        return ResponseEntity.ok(ApiResponse.success(contact));
    }

    @DeleteMapping("/contacts/{contactId}")
    public ResponseEntity<ApiResponse<Void>> removeTrustedContact(
            @AuthenticationPrincipal String userId,
            @PathVariable UUID contactId) {
        log.debug("SOS_CTRL - DELETE /api/user/sos/contacts/{} | userId: {}", contactId, userId);
        sosService.removeTrustedContact(userId, contactId);
        log.debug("SOS_CTRL - DELETE /api/user/sos/contacts/{} RESPONSE: 200 OK | userId: {}", contactId, userId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @PostMapping("/trigger")
    public ResponseEntity<ApiResponse<SOSEventResponse>> triggerSOS(
            @AuthenticationPrincipal String userId,
            @Valid @RequestBody TriggerSOSRequest request) {
        log.debug("SOS_CTRL - POST /api/user/sos/trigger | userId: {} | lat: {} | lng: {}",
                userId, request.getLatitude(), request.getLongitude());
        SOSEventResponse event = sosService.triggerSOS(userId, request);
        log.debug("SOS_CTRL - POST /api/user/sos/trigger RESPONSE: 200 OK | userId: {} | eventId: {}",
                userId, event.getId());
        return ResponseEntity.ok(ApiResponse.success(event));
    }

    @GetMapping("/events")
    public ResponseEntity<ApiResponse<List<SOSEventResponse>>> getUserEvents(
            @AuthenticationPrincipal String userId) {
        log.debug("SOS_CTRL - GET /api/user/sos/events | userId: {}", userId);
        List<SOSEventResponse> events = sosService.getUserEvents(userId);
        log.debug("SOS_CTRL - GET /api/user/sos/events RESPONSE: 200 OK | userId: {} | count: {}",
                userId, events.size());
        return ResponseEntity.ok(ApiResponse.success(events));
    }
}
