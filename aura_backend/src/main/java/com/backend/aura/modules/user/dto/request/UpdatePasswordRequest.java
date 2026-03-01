package com.backend.aura.modules.user.dto.request;

import lombok.Data;

@Data
public class UpdatePasswordRequest {
    private String uid;
    private String currentPassword;
    private String newPassword;
}
