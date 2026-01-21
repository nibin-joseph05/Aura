package com.backend.aura.modules.reminder.dto;

import lombok.Data;

import java.time.LocalTime;
import java.util.UUID;

@Data
public class ReminderRequest {
    private UUID userActivityId;
    private LocalTime reminderTime;
    private Boolean isEnabled;
}
