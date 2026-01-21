package com.backend.aura.modules.sos.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TrustedContactResponse {
    private UUID id;
    private String name;
    private String phone;
    private String email;
    private String relationship;
    private Integer priority;
    private Boolean isActive;
}
