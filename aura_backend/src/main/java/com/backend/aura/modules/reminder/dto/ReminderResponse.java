package com.backend.aura.modules.reminder.dto;

import com.backend.aura.modules.reminder.model.Reminder;
import lombok.Data;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.UUID;

@Data
public class ReminderResponse {
    private UUID id;
    private UUID userActivityId;
    private String activityName;
    private LocalTime reminderTime;
    private Boolean isEnabled;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public static ReminderResponse fromEntity(Reminder reminder) {
        ReminderResponse response = new ReminderResponse();
        response.setId(reminder.getId());
        response.setUserActivityId(reminder.getUserActivity().getId());

        String activityName = reminder.getUserActivity().getCustomTitle();
        if (activityName == null || activityName.isBlank()) {
            activityName = reminder.getUserActivity().getActivityType().getName();
        }
        response.setActivityName(activityName);

        response.setReminderTime(reminder.getReminderTime());
        response.setIsEnabled(reminder.getIsEnabled());
        response.setCreatedAt(reminder.getCreatedAt());
        response.setUpdatedAt(reminder.getUpdatedAt());
        return response;
    }
}
