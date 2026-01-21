package com.backend.aura.modules.sos.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SOSStatsResponse {
    private long totalEvents;
    private long activeEvents;
    private long resolvedEvents;
    private long eventsToday;
    private long eventsThisWeek;
    private long eventsThisMonth;
}
