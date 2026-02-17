package com.backend.aura.modules.sos.dto;

import lombok.Data;

@Data
public class LiveLocationUpdateRequest {
    private Double latitude;
    private Double longitude;
    private Double altitude;
    private Double speed;
}
