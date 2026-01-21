package com.backend.aura.modules.sos.dto;

import com.backend.aura.modules.sos.model.enums.SOSEventStatus;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SOSEventResponse {
    private UUID id;
    private String userId;
    private String userName;
    private String userPhone;
    private Double latitude;
    private Double longitude;
    private String address;
    private String message;
    private Integer contactsNotified;
    private SOSEventStatus status;
    private LocalDateTime triggeredAt;
    private LocalDateTime acknowledgedAt;
    private LocalDateTime resolvedAt;
    private String resolvedBy;
    private String resolutionNotes;
    private Boolean syncedFromOffline;
    private String mapsUrl;
}
