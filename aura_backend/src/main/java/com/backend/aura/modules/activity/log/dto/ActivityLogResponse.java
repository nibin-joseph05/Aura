package com.backend.aura.modules.activity.log.dto;

import com.backend.aura.modules.activity.log.model.ActivityLog;
import com.backend.aura.modules.activity.log.model.enums.ActivityStatus;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;
import java.util.List;
import java.util.stream.Collectors;

@Data
public class ActivityLogResponse {
    private UUID id;
    private UUID userActivityId;
    private String activityTypeName;
    private String activityTypeIcon;
    private String customTitle;
    private LocalDate logDate;
    private ActivityStatus status;
    private List<ActivityLogMetricDto> metrics;
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
        if (log.getMetrics() != null) {
            response.setMetrics(log.getMetrics().stream().map(m -> {
                ActivityLogMetricDto dto = new ActivityLogMetricDto();
                dto.setId(m.getId());
                dto.setActivityMetricId(m.getActivityMetric().getId());
                dto.setName(m.getActivityMetric().getName());
                dto.setUnit(m.getActivityMetric().getUnit());
                dto.setValue(m.getMetricValue());
                return dto;
            }).collect(Collectors.toList()));
        }
        response.setNote(log.getNote());
        response.setCompletedAt(log.getCompletedAt());
        response.setCreatedAt(log.getCreatedAt());
        response.setUpdatedAt(log.getUpdatedAt());
        return response;
    }
}
