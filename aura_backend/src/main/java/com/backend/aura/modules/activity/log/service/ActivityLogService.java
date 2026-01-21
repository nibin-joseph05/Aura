package com.backend.aura.modules.activity.log.service;

import com.backend.aura.modules.activity.log.dto.ActivityLogRequest;
import com.backend.aura.modules.activity.log.dto.ActivityLogResponse;
import com.backend.aura.modules.activity.log.model.ActivityLog;
import com.backend.aura.modules.activity.log.model.enums.ActivityStatus;
import com.backend.aura.modules.activity.log.repository.ActivityLogRepository;
import com.backend.aura.modules.activity.useractivity.model.UserActivity;
import com.backend.aura.modules.activity.useractivity.repository.UserActivityRepository;
import com.backend.aura.modules.common.exception.NotFoundException;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class ActivityLogService {

    private final ActivityLogRepository logRepository;
    private final UserActivityRepository userActivityRepository;

    public ActivityLogService(
            ActivityLogRepository logRepository,
            UserActivityRepository userActivityRepository) {
        this.logRepository = logRepository;
        this.userActivityRepository = userActivityRepository;
    }

    public List<ActivityLogResponse> getLogsForDate(String userId, LocalDate date) {
        return logRepository.findByUserIdAndDate(userId, date)
                .stream()
                .map(ActivityLogResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public List<ActivityLogResponse> getLogsForDateRange(String userId, LocalDate startDate, LocalDate endDate) {
        return logRepository.findByUserIdAndDateRange(userId, startDate, endDate)
                .stream()
                .map(ActivityLogResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public ActivityLogResponse getLogById(UUID id) {
        ActivityLog log = logRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Activity log not found"));
        return ActivityLogResponse.fromEntity(log);
    }

    public ActivityLogResponse createLog(ActivityLogRequest request) {
        if (request.getUserActivityId() == null) {
            throw new IllegalArgumentException("User activity ID is required");
        }

        UserActivity userActivity = userActivityRepository.findById(request.getUserActivityId())
                .orElseThrow(() -> new NotFoundException("User activity not found"));

        LocalDate logDate = request.getLogDate() != null ? request.getLogDate() : LocalDate.now();

        if (logRepository.existsByUserActivityIdAndLogDate(request.getUserActivityId(), logDate)) {
            throw new IllegalArgumentException("Log already exists for this activity on this date");
        }

        ActivityLog log = new ActivityLog();
        log.setUserActivity(userActivity);
        log.setLogDate(logDate);
        log.setStatus(request.getStatus() != null ? request.getStatus() : ActivityStatus.PENDING);
        log.setActualDuration(request.getActualDuration());
        log.setDistanceKm(request.getDistanceKm());
        log.setCaloriesBurned(request.getCaloriesBurned());
        log.setNote(request.getNote());

        if (request.getStatus() == ActivityStatus.COMPLETED) {
            log.setCompletedAt(LocalDateTime.now());
        }

        ActivityLog saved = logRepository.save(log);
        return ActivityLogResponse.fromEntity(saved);
    }

    public ActivityLogResponse updateLog(UUID id, ActivityLogRequest request) {
        ActivityLog log = logRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Activity log not found"));

        if (request.getStatus() != null) {
            log.setStatus(request.getStatus());
            if (request.getStatus() == ActivityStatus.COMPLETED && log.getCompletedAt() == null) {
                log.setCompletedAt(LocalDateTime.now());
            }
        }
        if (request.getActualDuration() != null) {
            log.setActualDuration(request.getActualDuration());
        }
        if (request.getDistanceKm() != null) {
            log.setDistanceKm(request.getDistanceKm());
        }
        if (request.getCaloriesBurned() != null) {
            log.setCaloriesBurned(request.getCaloriesBurned());
        }
        if (request.getNote() != null) {
            log.setNote(request.getNote());
        }

        ActivityLog saved = logRepository.save(log);
        return ActivityLogResponse.fromEntity(saved);
    }

    public ActivityLogResponse markAsCompleted(UUID id) {
        ActivityLog log = logRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Activity log not found"));
        log.setStatus(ActivityStatus.COMPLETED);
        log.setCompletedAt(LocalDateTime.now());
        ActivityLog saved = logRepository.save(log);
        return ActivityLogResponse.fromEntity(saved);
    }

    public ActivityLogResponse markAsSkipped(UUID id) {
        ActivityLog log = logRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Activity log not found"));
        log.setStatus(ActivityStatus.SKIPPED);
        ActivityLog saved = logRepository.save(log);
        return ActivityLogResponse.fromEntity(saved);
    }

    public void deleteLog(UUID id) {
        if (!logRepository.existsById(id)) {
            throw new NotFoundException("Activity log not found");
        }
        logRepository.deleteById(id);
    }
}
