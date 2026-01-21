package com.backend.aura.modules.activity.useractivity.dto;

import com.backend.aura.modules.activity.useractivity.model.UserActivity;
import com.backend.aura.modules.activity.useractivity.model.enums.RepeatType;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.UUID;

@Data
public class UserActivityResponse {
    private UUID id;
    private String userId;
    private UUID activityTypeId;
    private String activityTypeName;
    private String activityTypeIcon;
    private String categoryName;
    private Boolean isGymActivity;
    private String customTitle;
    private LocalTime scheduledTime;
    private RepeatType repeatType;
    private String repeatDays;
    private LocalDate startDate;
    private LocalDate endDate;
    private Boolean isActive;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public static UserActivityResponse fromEntity(UserActivity activity) {
        UserActivityResponse response = new UserActivityResponse();
        response.setId(activity.getId());
        response.setUserId(activity.getUserId());
        response.setActivityTypeId(activity.getActivityType().getId());
        response.setActivityTypeName(activity.getActivityType().getName());
        response.setActivityTypeIcon(activity.getActivityType().getIcon());
        response.setCategoryName(activity.getActivityType().getCategory().getName());
        response.setIsGymActivity(activity.getActivityType().getIsGymActivity());
        response.setCustomTitle(activity.getCustomTitle());
        response.setScheduledTime(activity.getScheduledTime());
        response.setRepeatType(activity.getRepeatType());
        response.setRepeatDays(activity.getRepeatDays());
        response.setStartDate(activity.getStartDate());
        response.setEndDate(activity.getEndDate());
        response.setIsActive(activity.getIsActive());
        response.setCreatedAt(activity.getCreatedAt());
        response.setUpdatedAt(activity.getUpdatedAt());
        return response;
    }
}
