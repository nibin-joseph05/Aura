package com.backend.aura.modules.sos.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SOSSettingsResponse {
    private UUID id;
    private String userId;
    private String customMessage;
    private Boolean isActive;
    private List<TrustedContactResponse> contacts;
    private int totalContacts;
}
