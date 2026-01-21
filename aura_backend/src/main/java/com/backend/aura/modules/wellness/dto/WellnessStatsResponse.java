package com.backend.aura.modules.wellness.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class WellnessStatsResponse {
    private long totalUpdates;
    private long approvedUpdates;
    private long pendingUpdates;
    private long todayUpdates;
}
