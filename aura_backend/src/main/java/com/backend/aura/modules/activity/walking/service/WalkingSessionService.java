package com.backend.aura.modules.activity.walking.service;

import com.backend.aura.modules.activity.walking.dto.RoutePointDTO;
import com.backend.aura.modules.activity.walking.dto.WalkingSessionDTO;
import com.backend.aura.modules.activity.walking.model.WalkingSession;
import com.backend.aura.modules.activity.walking.repository.WalkingSessionRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class WalkingSessionService {

    private final WalkingSessionRepository repository;
    private final ObjectMapper objectMapper;

    @Transactional
    public WalkingSessionDTO startSession(String userId) {
        Optional<WalkingSession> existing = repository.findByUserIdAndIsActiveTrue(userId);
        if (existing.isPresent()) {
            return toDTO(existing.get());
        }

        WalkingSession session = WalkingSession.builder()
                .userId(userId)
                .startTime(LocalDateTime.now())
                .isActive(true)
                .build();

        WalkingSession saved = repository.save(session);
        return toDTO(saved);
    }

    @Transactional
    public WalkingSessionDTO endSession(String userId, String sessionId, double distanceMeters, int stepsCount) {
        WalkingSession session = repository.findById(sessionId)
                .orElseThrow(() -> new RuntimeException("Session not found"));

        if (!session.getUserId().equals(userId)) {
            throw new RuntimeException("Unauthorized");
        }

        session.setEndTime(LocalDateTime.now());
        session.setActive(false);
        session.setDistanceMeters(distanceMeters);
        session.setStepsCount(stepsCount);
        session.setDurationSeconds((int) ChronoUnit.SECONDS.between(session.getStartTime(), session.getEndTime()));
        session.setCaloriesBurned(calculateCalories(distanceMeters, session.getDurationSeconds()));

        WalkingSession saved = repository.save(session);
        return toDTO(saved);
    }

    @Transactional
    public WalkingSessionDTO addRoutePoints(String userId, String sessionId, List<RoutePointDTO> points) {
        WalkingSession session = repository.findById(sessionId)
                .orElseThrow(() -> new RuntimeException("Session not found"));

        if (!session.getUserId().equals(userId)) {
            throw new RuntimeException("Unauthorized");
        }

        List<RoutePointDTO> existingPoints = parseRoutePoints(session.getRoutePointsJson());
        existingPoints.addAll(points);
        session.setRoutePointsJson(serializeRoutePoints(existingPoints));

        WalkingSession saved = repository.save(session);
        return toDTO(saved);
    }

    public Optional<WalkingSessionDTO> getActiveSession(String userId) {
        return repository.findByUserIdAndIsActiveTrue(userId).map(this::toDTO);
    }

    public Page<WalkingSessionDTO> getHistory(String userId, Pageable pageable) {
        return repository.findByUserIdOrderByCreatedAtDesc(userId, pageable).map(this::toDTO);
    }

    public WalkingStatsDTO getStats(String userId) {
        long totalSessions = repository.countByUserIdAndIsActiveFalse(userId);
        List<WalkingSession> sessions = repository.findByUserIdAndIsActiveFalseOrderByCreatedAtDesc(userId);

        double totalDistance = sessions.stream().mapToDouble(WalkingSession::getDistanceMeters).sum();
        int totalDuration = sessions.stream().mapToInt(WalkingSession::getDurationSeconds).sum();
        int totalSteps = sessions.stream().mapToInt(WalkingSession::getStepsCount).sum();
        double totalCalories = sessions.stream().mapToDouble(WalkingSession::getCaloriesBurned).sum();

        return WalkingStatsDTO.builder()
                .totalSessions(totalSessions)
                .totalDistanceMeters(totalDistance)
                .totalDurationSeconds(totalDuration)
                .totalSteps(totalSteps)
                .totalCaloriesBurned(totalCalories)
                .build();
    }

    private double calculateCalories(double distanceMeters, int durationSeconds) {
        double distanceKm = distanceMeters / 1000.0;
        return distanceKm * 50;
    }

    private WalkingSessionDTO toDTO(WalkingSession session) {
        return WalkingSessionDTO.builder()
                .id(session.getId())
                .userId(session.getUserId())
                .startTime(session.getStartTime().toString())
                .endTime(session.getEndTime() != null ? session.getEndTime().toString() : null)
                .distanceMeters(session.getDistanceMeters())
                .durationSeconds(session.getDurationSeconds())
                .stepsCount(session.getStepsCount())
                .caloriesBurned(session.getCaloriesBurned())
                .isActive(session.isActive())
                .routePoints(parseRoutePoints(session.getRoutePointsJson()))
                .createdAt(session.getCreatedAt().toString())
                .build();
    }

    private List<RoutePointDTO> parseRoutePoints(String json) {
        if (json == null || json.isBlank())
            return new ArrayList<>();
        try {
            return objectMapper.readValue(json, new TypeReference<List<RoutePointDTO>>() {
            });
        } catch (JsonProcessingException e) {
            return new ArrayList<>();
        }
    }

    private String serializeRoutePoints(List<RoutePointDTO> points) {
        try {
            return objectMapper.writeValueAsString(points);
        } catch (JsonProcessingException e) {
            return "[]";
        }
    }

    @lombok.Data
    @lombok.Builder
    @lombok.NoArgsConstructor
    @lombok.AllArgsConstructor
    public static class WalkingStatsDTO {
        private long totalSessions;
        private double totalDistanceMeters;
        private int totalDurationSeconds;
        private int totalSteps;
        private double totalCaloriesBurned;
    }
}
