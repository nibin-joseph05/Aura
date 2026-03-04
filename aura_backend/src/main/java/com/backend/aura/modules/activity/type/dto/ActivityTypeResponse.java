package com.backend.aura.modules.activity.type.dto;

import com.backend.aura.modules.activity.type.model.ActivityType;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;
import java.util.List;
import java.util.stream.Collectors;

@Data
public class ActivityTypeResponse {
    private UUID id;
    private UUID categoryId;
    private String categoryName;
    private String name;
    private String description;
    private Boolean allowAlarm;
    private Boolean allowNotes;
    private List<ActivityMetricDto> metrics;
    private Boolean isGymActivity;
    private String icon;
    private String color;
    private Integer defaultIntervalMinutes;
    private Integer defaultTargetCompletions;
    private Boolean isActive;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public static ActivityTypeResponse fromEntity(ActivityType type) {
        ActivityTypeResponse response = new ActivityTypeResponse();
        response.setId(type.getId());
        response.setCategoryId(type.getCategory().getId());
        response.setCategoryName(type.getCategory().getName());
        response.setName(type.getName());
        response.setDescription(type.getDescription());
        response.setAllowAlarm(type.getAllowAlarm());
        response.setAllowNotes(type.getAllowNotes());
        if (type.getMetrics() != null) {
            response.setMetrics(type.getMetrics().stream().map(m -> {
                ActivityMetricDto dto = new ActivityMetricDto();
                dto.setId(m.getId());
                dto.setName(m.getName());
                dto.setUnit(m.getUnit());
                dto.setMetricType(m.getMetricType());
                dto.setIsRequired(m.getIsRequired());
                return dto;
            }).collect(Collectors.toList()));
        }
        response.setIsGymActivity(type.getIsGymActivity());
        response.setIcon(type.getIcon());
        response.setColor(type.getColor());
        response.setDefaultIntervalMinutes(type.getDefaultIntervalMinutes());
        response.setDefaultTargetCompletions(type.getDefaultTargetCompletions());
        response.setIsActive(type.getIsActive());
        response.setCreatedAt(type.getCreatedAt());
        response.setUpdatedAt(type.getUpdatedAt());
        return response;
    }
}
