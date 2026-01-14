package com.backend.aura.modules.auth.admin.dto.response;

import com.backend.aura.modules.admin.model.Admin;
import com.backend.aura.modules.admin.model.enums.AdminRole;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AdminResponse {
    private UUID id;
    private String name;
    private String email;
    private AdminRole role;
    private Boolean isActive;
    private LocalDateTime lastLoginAt;
    private LocalDateTime createdAt;

    public static AdminResponse fromEntity(Admin admin) {
        AdminResponse response = new AdminResponse();
        response.setId(admin.getId());
        response.setName(admin.getName());
        response.setEmail(admin.getEmail());
        response.setRole(admin.getRole());
        response.setIsActive(admin.getIsActive());
        response.setLastLoginAt(admin.getLastLoginAt());
        response.setCreatedAt(admin.getCreatedAt());
        return response;
    }
}
