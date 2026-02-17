package com.backend.aura.modules.sos.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LiveLocationPointResponse {
    private UUID id;
    private Double latitude;
    private Double longitude;
    private LocalDateTime timestamp;
    private Double altitude;
    private Double speed;
}
