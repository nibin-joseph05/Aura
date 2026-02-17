package com.backend.aura.modules.sos.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LiveLocationSessionResponse {
    private UUID id;
    private String userId;
    private Boolean active;
    private LocalDateTime startedAt;
    private LocalDateTime endedAt;
    private Integer durationMinutes;
    private List<String> allowedContactIds;
    private String blockHash;
    private Long blockIndex;
    private List<LiveLocationPointResponse> points;
}
