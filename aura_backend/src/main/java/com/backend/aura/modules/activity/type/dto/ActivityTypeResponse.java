package com.backend.aura.modules.activity.type.dto;

import com.backend.aura.modules.activity.type.model.ActivityType;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class ActivityTypeResponse {
    private UUID id;
    private UUID categoryId;
    private String categoryName;
    private String name;
    private String description;
    private Boolean allowAlarm;
    private Boolean allowNotes;
    private Boolean requiresDuration;
    private Boolean requiresDistance;
    private Boolean requiresCalories;
    private Boolean isGymActivity;
    private String icon;
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
        response.setRequiresDuration(type.getRequiresDuration());
        response.setRequiresDistance(type.getRequiresDistance());
        response.setRequiresCalories(type.getRequiresCalories());
        response.setIsGymActivity(type.getIsGymActivity());
        response.setIcon(type.getIcon());
        response.setIsActive(type.getIsActive());
        response.setCreatedAt(type.getCreatedAt());
        response.setUpdatedAt(type.getUpdatedAt());
        return response;
    }
}
