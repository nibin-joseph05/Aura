package com.backend.aura.modules.auth.admin.dto.request;

import lombok.Data;

@Data
public class AdminRegisterRequest {
    private String name;
    private String email;
    private String password;
}
