package com.backend.aura.modules.activity.type.dto;

import lombok.Data;

import java.util.UUID;
import java.util.List;

@Data
public class ActivityTypeRequest {
    private UUID categoryId;
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
}
