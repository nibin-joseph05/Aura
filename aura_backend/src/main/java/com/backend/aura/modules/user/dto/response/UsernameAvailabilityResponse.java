package com.backend.aura.modules.user.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class UsernameAvailabilityResponse {
    private boolean available;
}
