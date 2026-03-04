package com.backend.aura.modules.activity.type.dto;

import com.backend.aura.modules.activity.type.model.enums.MetricType;
import lombok.Data;

import java.util.UUID;

@Data
public class ActivityMetricDto {
    private UUID id;
    private String name;
    private String unit;
    private MetricType metricType;
    private Boolean isRequired;
}
