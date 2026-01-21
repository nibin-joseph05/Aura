package com.backend.aura.modules.sos.dto;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TriggerSOSRequest {
    @NotNull(message = "Latitude is required")
    private Double latitude;

    @NotNull(message = "Longitude is required")
    private Double longitude;

    private String address;

    private String customMessage;

    private Integer contactsNotified;

    private Boolean syncedFromOffline = false;

    private LocalDateTime triggeredAt;

    private String deviceInfo;
}
