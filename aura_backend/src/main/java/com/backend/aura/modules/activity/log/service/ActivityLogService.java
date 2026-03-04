package com.backend.aura.modules.activity.log.service;

import com.backend.aura.modules.activity.log.dto.ActivityLogRequest;
import com.backend.aura.modules.activity.log.dto.ActivityLogResponse;
import com.backend.aura.modules.activity.log.model.ActivityLog;
import com.backend.aura.modules.activity.log.model.enums.ActivityStatus;
import com.backend.aura.modules.activity.log.repository.ActivityLogRepository;
import com.backend.aura.modules.activity.useractivity.model.UserActivity;
import com.backend.aura.modules.activity.useractivity.repository.UserActivityRepository;
import com.backend.aura.modules.activity.log.model.ActivityLogMetric;
import com.backend.aura.modules.common.exception.NotFoundException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Slf4j
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

        ActivityLog activityLog = new ActivityLog();
        activityLog.setUserActivity(userActivity);
        activityLog.setLogDate(logDate);
        activityLog.setStatus(request.getStatus() != null ? request.getStatus() : ActivityStatus.PENDING);
        if (request.getMetrics() != null) {
            List<ActivityLogMetric> logMetrics = request.getMetrics().entrySet().stream().map(entry -> {
                ActivityLogMetric lm = new ActivityLogMetric();
                lm.setActivityLog(activityLog);
                com.backend.aura.modules.activity.type.model.ActivityMetric am = userActivity.getActivityType()
                        .getMetrics().stream()
                        .filter(m -> m.getId().equals(entry.getKey()))
                        .findFirst()
                        .orElseThrow(() -> {
                            log.error("Failed to map log metric. Invalid metric ID specified: {} for activity {}",
                                    entry.getKey(), userActivity.getActivityType().getName());
                            return new IllegalArgumentException("Invalid metric ID: " + entry.getKey());
                        });
                lm.setActivityMetric(am);
                lm.setMetricValue(entry.getValue());
                return lm;
            }).collect(Collectors.toList());
            activityLog.setMetrics(logMetrics);
        }
        activityLog.setNote(request.getNote());

        if (request.getStatus() == ActivityStatus.COMPLETED) {
            activityLog.setCompletedAt(LocalDateTime.now());
        }

        ActivityLog saved = logRepository.save(activityLog);
        return ActivityLogResponse.fromEntity(saved);
    }

    public ActivityLogResponse updateLog(UUID id, ActivityLogRequest request) {
        ActivityLog activityLog = logRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Activity log not found"));

        if (request.getStatus() != null) {
            activityLog.setStatus(request.getStatus());
            if (request.getStatus() == ActivityStatus.COMPLETED && activityLog.getCompletedAt() == null) {
                activityLog.setCompletedAt(LocalDateTime.now());
            }
        }
        if (request.getMetrics() != null) {
            activityLog.getMetrics().clear();
            List<ActivityLogMetric> logMetrics = request.getMetrics().entrySet().stream().map(entry -> {
                ActivityLogMetric lm = new ActivityLogMetric();
                lm.setActivityLog(activityLog);
                com.backend.aura.modules.activity.type.model.ActivityMetric am = activityLog.getUserActivity()
                        .getActivityType()
                        .getMetrics().stream()
                        .filter(m -> m.getId().equals(entry.getKey()))
                        .findFirst()
                        .orElseThrow(() -> {
                            log.error(
                                    "Failed to map log metric during update. Invalid metric ID specified: {} for activity log {}",
                                    entry.getKey(), activityLog.getId());
                            return new IllegalArgumentException("Invalid metric ID: " + entry.getKey());
                        });
                lm.setActivityMetric(am);
                lm.setMetricValue(entry.getValue());
                return lm;
            }).collect(Collectors.toList());
            activityLog.getMetrics().addAll(logMetrics);
        }
        if (request.getNote() != null) {
            activityLog.setNote(request.getNote());
        }

        ActivityLog saved = logRepository.save(activityLog);
        return ActivityLogResponse.fromEntity(saved);
    }

    public ActivityLogResponse markAsCompleted(UUID id) {
        ActivityLog activityLog = logRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Activity log not found"));
        activityLog.setStatus(ActivityStatus.COMPLETED);
        activityLog.setCompletedAt(LocalDateTime.now());
        ActivityLog saved = logRepository.save(activityLog);
        return ActivityLogResponse.fromEntity(saved);
    }

    public ActivityLogResponse markAsSkipped(UUID id) {
        ActivityLog activityLog = logRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Activity log not found"));
        activityLog.setStatus(ActivityStatus.SKIPPED);
        ActivityLog saved = logRepository.save(activityLog);
        return ActivityLogResponse.fromEntity(saved);
    }

    public void deleteLog(UUID id) {
        if (!logRepository.existsById(id)) {
            throw new NotFoundException("Activity log not found");
        }
        logRepository.deleteById(id);
    }
}
