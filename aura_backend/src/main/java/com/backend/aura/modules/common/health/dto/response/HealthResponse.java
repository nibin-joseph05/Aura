package com.backend.aura.modules.common.health.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class HealthResponse {
    private String status;
    private String service;
    private long timestamp;
}
