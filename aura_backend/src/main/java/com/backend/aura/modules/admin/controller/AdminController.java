package com.backend.aura.modules.admin.controller;

import com.backend.aura.modules.admin.dto.AdminProfileDTO;
import com.backend.aura.modules.admin.dto.AdminStatsDTO;
import com.backend.aura.modules.admin.service.AdminService;
import com.backend.aura.modules.common.dto.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminController {

    private final AdminService adminService;

    @GetMapping("/stats")
    public ResponseEntity<ApiResponse<AdminStatsDTO>> getDashboardStats() {
        AdminStatsDTO stats = adminService.getDashboardStats();
        return ResponseEntity.ok(ApiResponse.success(stats));
    }

    @GetMapping("/profile")
    public ResponseEntity<ApiResponse<AdminProfileDTO>> getProfile(@RequestHeader("X-Admin-Id") String adminId) {
        return adminService.getProfile(adminId)
                .map(profile -> ResponseEntity.ok(ApiResponse.success(profile)))
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/profile")
    public ResponseEntity<ApiResponse<AdminProfileDTO>> updateProfile(
            @RequestHeader("X-Admin-Id") String adminId,
            @RequestBody Map<String, String> body) {
        String name = body.get("name");
        String email = body.get("email");
        return adminService.updateProfile(adminId, name, email)
                .map(profile -> ResponseEntity.ok(ApiResponse.success(profile)))
                .orElse(ResponseEntity.notFound().build());
    }
}
