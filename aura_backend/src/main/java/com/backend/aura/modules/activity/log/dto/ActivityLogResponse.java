package com.backend.aura.modules.activity.log.dto;

import com.backend.aura.modules.activity.log.model.ActivityLog;
import com.backend.aura.modules.activity.log.model.enums.ActivityStatus;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class ActivityLogResponse {
    private UUID id;
    private UUID userActivityId;
    private String activityTypeName;
    private String activityTypeIcon;
    private String customTitle;
    private LocalDate logDate;
    private ActivityStatus status;
    private Integer actualDuration;
    private BigDecimal distanceKm;
    private Integer caloriesBurned;
    private String note;
    private LocalDateTime completedAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public static ActivityLogResponse fromEntity(ActivityLog log) {
        ActivityLogResponse response = new ActivityLogResponse();
        response.setId(log.getId());
        response.setUserActivityId(log.getUserActivity().getId());
        response.setActivityTypeName(log.getUserActivity().getActivityType().getName());
        response.setActivityTypeIcon(log.getUserActivity().getActivityType().getIcon());
        response.setCustomTitle(log.getUserActivity().getCustomTitle());
        response.setLogDate(log.getLogDate());
        response.setStatus(log.getStatus());
        response.setActualDuration(log.getActualDuration());
        response.setDistanceKm(log.getDistanceKm());
        response.setCaloriesBurned(log.getCaloriesBurned());
        response.setNote(log.getNote());
        response.setCompletedAt(log.getCompletedAt());
        response.setCreatedAt(log.getCreatedAt());
        response.setUpdatedAt(log.getUpdatedAt());
        return response;
    }
}
