package com.backend.aura.modules.activity.log.dto;

import com.backend.aura.modules.activity.log.model.enums.ActivityStatus;
import lombok.Data;

import java.time.LocalDate;
import java.util.UUID;
import java.util.Map;

@Data
public class ActivityLogRequest {
    private UUID userActivityId;
    private LocalDate logDate;
    private ActivityStatus status;
    private Map<UUID, String> metrics;
    private String note;
}
