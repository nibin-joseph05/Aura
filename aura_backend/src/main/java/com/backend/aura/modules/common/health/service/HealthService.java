package com.backend.aura.modules.common.health.service;

import com.backend.aura.modules.common.health.dto.response.HealthResponse;
import org.springframework.stereotype.Service;

@Service
public class HealthService {

    public HealthResponse getHealth() {
        return new HealthResponse(
                "UP",
                "Aura Backend",
                System.currentTimeMillis()
        );
    }
}
