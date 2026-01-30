package com.backend.aura.modules.activity.walking.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RoutePointDTO {
    private double latitude;
    private double longitude;
    private long timestamp;
    private double altitude;
    private double speed;
}
