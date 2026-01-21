package com.backend.aura.modules.activity.log.dto;

import com.backend.aura.modules.activity.log.model.enums.ActivityStatus;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Data
public class ActivityLogRequest {
    private UUID userActivityId;
    private LocalDate logDate;
    private ActivityStatus status;
    private Integer actualDuration;
    private BigDecimal distanceKm;
    private Integer caloriesBurned;
    private String note;
}
