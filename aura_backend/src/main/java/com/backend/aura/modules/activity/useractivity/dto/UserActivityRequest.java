package com.backend.aura.modules.activity.useractivity.dto;

import com.backend.aura.modules.activity.useractivity.model.enums.RepeatType;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

@Data
public class UserActivityRequest {
    private UUID activityTypeId;
    private String customTitle;
    private LocalTime scheduledTime;
    private RepeatType repeatType;
    private String repeatDays;
    private LocalDate startDate;
    private LocalDate endDate;
    private Integer intervalMinutes;
    private Integer targetCompletions;
    private Boolean isAlarmEnabled;
    private Boolean isPushEnabled;
    private Boolean isActive;
}
