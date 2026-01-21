package com.backend.aura.modules.sos.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UpdateSOSMessageRequest {
    @NotBlank(message = "Custom message is required")
    private String customMessage;
}
