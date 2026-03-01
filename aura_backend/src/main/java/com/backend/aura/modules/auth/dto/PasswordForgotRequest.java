package com.backend.aura.modules.auth.dto;

import lombok.Data;

@Data
public class PasswordForgotRequest {
    private String email;
}
