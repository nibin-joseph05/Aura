package com.backend.aura.modules.sos.service;

import com.backend.aura.core.logging.AuraLogger;
import com.backend.aura.modules.blockchain.service.BlockchainService;
import com.backend.aura.modules.sos.dto.*;
import com.backend.aura.modules.sos.model.LiveLocationPoint;
import com.backend.aura.modules.sos.model.LiveLocationSession;
import com.backend.aura.modules.sos.repository.LiveLocationRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class LiveLocationService {

    private final LiveLocationRepository liveLocationRepository;
    private final BlockchainService blockchainService;
    private final SimpMessagingTemplate messagingTemplate;
    private final AuraLogger auraLogger;

    @Transactional
    public LiveLocationSessionResponse startSession(String userId, StartLiveLocationRequest request) {
        liveLocationRepository.findByUserIdAndActiveTrue(userId).ifPresent(existing -> {
            existing.setActive(false);
            existing.setEndedAt(LocalDateTime.now());
            liveLocationRepository.save(existing);
        });

        LiveLocationSession session = new LiveLocationSession();
        session.setUserId(userId);
        session.setActive(true);
        session.setDurationMinutes(request.getDurationMinutes());
        session.setAllowedContactIds(request.getAllowedContactIds() != null
                ? request.getAllowedContactIds()
                : new ArrayList<>());

        LiveLocationSession saved = liveLocationRepository.save(session);

        try {
            blockchainService.writeSosEvent(
                    "LIVE_" + saved.getId().toString(),
                    userId, 0.0, 0.0).ifPresent(result -> {
                        saved.setBlockHash(result.blockHash());
                        saved.setBlockIndex(result.blockIndex());
                        liveLocationRepository.save(saved);
                    });
        } catch (Exception e) {
            log.warn("Blockchain write skipped for live session {}: {}", saved.getId(), e.getMessage());
        }

        auraLogger.sosTriggered(userId, "LIVE_" + saved.getId().toString());
        return mapToResponse(saved);
    }

    @Transactional
    public LiveLocationSessionResponse stopSession(String userId) {
        LiveLocationSession session = liveLocationRepository.findByUserIdAndActiveTrue(userId)
                .orElseThrow(() -> new RuntimeException("No active live location session"));

        session.setActive(false);
        session.setEndedAt(LocalDateTime.now());
        LiveLocationSession saved = liveLocationRepository.save(session);

        for (String contactId : session.getAllowedContactIds()) {
            messagingTemplate.convertAndSendToUser(
                    contactId,
                    "/queue/live-location",
                    Map.of("type", "SESSION_ENDED", "sessionId", saved.getId().toString()));
        }

        auraLogger.sosResolved(saved.getId().toString(), userId);
        return mapToResponse(saved);
    }

    @Transactional
    public void addLocationPoint(String userId, UUID sessionId, LiveLocationUpdateRequest request) {
        LiveLocationSession session = liveLocationRepository.findById(sessionId)
                .orElseThrow(() -> new RuntimeException("Session not found"));

        if (!session.getUserId().equals(userId) || !session.getActive()) {
            throw new RuntimeException("Invalid session");
        }

        if (session.getDurationMinutes() != null) {
            LocalDateTime expiry = session.getStartedAt().plusMinutes(session.getDurationMinutes());
            if (LocalDateTime.now().isAfter(expiry)) {
                session.setActive(false);
                session.setEndedAt(expiry);
                liveLocationRepository.save(session);
                return;
            }
        }

        LiveLocationPoint point = new LiveLocationPoint();
        point.setSession(session);
        point.setLatitude(request.getLatitude());
        point.setLongitude(request.getLongitude());
        point.setAltitude(request.getAltitude());
        point.setSpeed(request.getSpeed());
        session.getPoints().add(point);
        liveLocationRepository.save(session);

        Map<String, Object> broadcast = Map.of(
                "type", "LOCATION_UPDATE",
                "sessionId", sessionId.toString(),
                "latitude", request.getLatitude(),
                "longitude", request.getLongitude(),
                "timestamp", LocalDateTime.now().toString());

        for (String contactId : session.getAllowedContactIds()) {
            messagingTemplate.convertAndSendToUser(
                    contactId,
                    "/queue/live-location",
                    broadcast);
        }
    }

    @Transactional(readOnly = true)
    public LiveLocationSessionResponse getSession(UUID sessionId) {
        LiveLocationSession session = liveLocationRepository.findById(sessionId)
                .orElseThrow(() -> new RuntimeException("Session not found"));
        return mapToResponse(session);
    }

    @Transactional(readOnly = true)
    public Optional<LiveLocationSessionResponse> getActiveSession(String userId) {
        return liveLocationRepository.findByUserIdAndActiveTrue(userId)
                .map(this::mapToResponse);
    }

    private LiveLocationSessionResponse mapToResponse(LiveLocationSession session) {
        List<LiveLocationPointResponse> pointResponses = session.getPoints() != null
                ? session.getPoints().stream()
                        .map(p -> LiveLocationPointResponse.builder()
                                .id(p.getId())
                                .latitude(p.getLatitude())
                                .longitude(p.getLongitude())
                                .timestamp(p.getTimestamp())
                                .altitude(p.getAltitude())
                                .speed(p.getSpeed())
                                .build())
                        .collect(Collectors.toList())
                : new ArrayList<>();

        return LiveLocationSessionResponse.builder()
                .id(session.getId())
                .userId(session.getUserId())
                .active(session.getActive())
                .startedAt(session.getStartedAt())
                .endedAt(session.getEndedAt())
                .durationMinutes(session.getDurationMinutes())
                .allowedContactIds(session.getAllowedContactIds())
                .blockHash(session.getBlockHash())
                .blockIndex(session.getBlockIndex())
                .points(pointResponses)
                .build();
    }
}
