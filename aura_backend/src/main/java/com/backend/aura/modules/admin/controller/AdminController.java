package com.backend.aura.modules.admin.controller;

import com.backend.aura.modules.admin.dto.AdminProfileDTO;
import com.backend.aura.modules.admin.dto.AdminStatsDTO;
import com.backend.aura.modules.admin.service.AdminService;
import com.backend.aura.modules.admin.service.OtpService;
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
    private final OtpService otpService;

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
        return adminService.updateProfileName(adminId, name)
                .map(profile -> ResponseEntity.ok(ApiResponse.success(profile)))
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/request-otp")
    public ResponseEntity<ApiResponse<String>> requestOtp(@RequestBody Map<String, String> body) {
        String email = body.get("email");
        String purpose = body.get("purpose");
        if (email == null || purpose == null) {
            return ResponseEntity.badRequest().body(ApiResponse.error("Email and purpose are required"));
        }
        otpService.generateAndSendOtp(email, purpose);
        return ResponseEntity.ok(ApiResponse.success("OTP sent to " + email));
    }

    @PostMapping("/verify-otp")
    public ResponseEntity<ApiResponse<Boolean>> verifyOtp(@RequestBody Map<String, String> body) {
        String email = body.get("email");
        String otp = body.get("otp");
        String purpose = body.get("purpose");
        if (email == null || otp == null || purpose == null) {
            return ResponseEntity.badRequest().body(ApiResponse.error("Email, OTP, and purpose are required"));
        }
        boolean verified = otpService.verifyOtp(email, otp, purpose);
        if (verified) {
            return ResponseEntity.ok(ApiResponse.success(true, "OTP verified successfully"));
        } else {
            return ResponseEntity.badRequest().body(ApiResponse.error("Invalid or expired OTP"));
        }
    }

    @PutMapping("/change-email")
    public ResponseEntity<ApiResponse<AdminProfileDTO>> changeEmail(
            @RequestHeader("X-Admin-Id") String adminId,
            @RequestBody Map<String, String> body) {
        String newEmail = body.get("newEmail");
        String otp = body.get("otp");
        if (newEmail == null || otp == null) {
            return ResponseEntity.badRequest().body(ApiResponse.error("New email and OTP are required"));
        }
        boolean verified = otpService.verifyOtp(newEmail, otp, "EMAIL_CHANGE");
        if (!verified) {
            return ResponseEntity.badRequest().body(ApiResponse.error("Invalid or expired OTP"));
        }
        return adminService.updateEmail(adminId, newEmail)
                .map(profile -> ResponseEntity.ok(ApiResponse.success(profile, "Email updated successfully")))
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/change-password")
    public ResponseEntity<ApiResponse<String>> changePassword(
            @RequestHeader("X-Admin-Id") String adminId,
            @RequestBody Map<String, String> body) {
        String currentPassword = body.get("currentPassword");
        String newPassword = body.get("newPassword");
        if (currentPassword == null || newPassword == null) {
            return ResponseEntity.badRequest().body(ApiResponse.error("Current and new passwords are required"));
        }
        boolean success = adminService.changePassword(adminId, currentPassword, newPassword);
        if (success) {
            return ResponseEntity.ok(ApiResponse.success("Password changed successfully"));
        } else {
            return ResponseEntity.badRequest().body(ApiResponse.error("Current password is incorrect"));
        }
    }
}
