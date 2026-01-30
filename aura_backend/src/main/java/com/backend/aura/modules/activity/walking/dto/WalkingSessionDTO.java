package com.backend.aura.modules.activity.walking.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WalkingSessionDTO {
    private String id;
    private String userId;
    private String startTime;
    private String endTime;
    private double distanceMeters;
    private int durationSeconds;
    private int stepsCount;
    private double caloriesBurned;
    private boolean isActive;
    private List<RoutePointDTO> routePoints;
    private String createdAt;
}
