package com.backend.aura.modules.sos.dto;

import lombok.Data;

import java.util.List;

@Data
public class StartLiveLocationRequest {
    private Integer durationMinutes;
    private List<String> allowedContactIds;
}
