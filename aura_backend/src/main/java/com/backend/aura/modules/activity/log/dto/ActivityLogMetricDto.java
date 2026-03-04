package com.backend.aura.modules.activity.log.dto;

import lombok.Data;
import java.util.UUID;

@Data
public class ActivityLogMetricDto {
    private UUID id;
    private UUID activityMetricId;
    private String name;
    private String unit;
    private String value;
}
