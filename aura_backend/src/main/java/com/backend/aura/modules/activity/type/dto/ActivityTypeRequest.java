package com.backend.aura.modules.activity.type.dto;

import lombok.Data;

import java.util.UUID;

@Data
public class ActivityTypeRequest {
    private UUID categoryId;
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
}
