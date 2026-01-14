package com.backend.aura.modules.auth.admin.service;

import com.backend.aura.config.security.jwt.JwtUtil;
import com.backend.aura.modules.admin.model.Admin;
import com.backend.aura.modules.admin.repository.AdminRepository;
import com.backend.aura.modules.auth.admin.dto.request.AdminLoginRequest;
import com.backend.aura.modules.auth.admin.dto.response.AdminLoginResponse;
import com.backend.aura.modules.auth.admin.dto.response.AdminResponse;
import com.backend.aura.modules.common.exception.AuthenticationException;
import com.backend.aura.modules.common.exception.NotFoundException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

@Service
public class AdminAuthService {

    private final AdminRepository adminRepository;
    private final BCryptPasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    public AdminAuthService(
            AdminRepository adminRepository,
            BCryptPasswordEncoder passwordEncoder,
            JwtUtil jwtUtil) {
        this.adminRepository = adminRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
    }

    public AdminLoginResponse login(AdminLoginRequest request) {
        if (request.getEmail() == null || request.getEmail().isBlank()) {
            throw new AuthenticationException("Email is required", "EMAIL_REQUIRED");
        }

        if (request.getPassword() == null || request.getPassword().isBlank()) {
            throw new AuthenticationException("Password is required", "PASSWORD_REQUIRED");
        }

        Optional<Admin> adminOpt = adminRepository.findByEmail(request.getEmail());

        if (adminOpt.isEmpty()) {
            throw new AuthenticationException(
                    "No account found with this email. Please check your email or contact support.",
                    "ACCOUNT_NOT_FOUND");
        }

        Admin admin = adminOpt.get();

        if (!admin.getIsActive()) {
            throw new AuthenticationException(
                    "Your account has been deactivated. Please contact support for assistance.",
                    "ACCOUNT_INACTIVE");
        }

        if (!passwordEncoder.matches(request.getPassword(), admin.getPassword())) {
            throw new AuthenticationException(
                    "Incorrect password. Please try again or reset your password.",
                    "INVALID_PASSWORD");
        }

        admin.setLastLoginAt(LocalDateTime.now());
        adminRepository.save(admin);

        String token = jwtUtil.generateToken(
                admin.getId(),
                admin.getEmail(),
                admin.getRole().name());

        return new AdminLoginResponse(token, "Login successful");
    }

    public AdminResponse getCurrentAdmin(String token) {
        if (token == null || token.isBlank()) {
            throw new AuthenticationException(
                    "Authentication token is missing. Please log in again.",
                    "TOKEN_MISSING");
        }

        String email;
        try {
            email = jwtUtil.extractEmail(token);
        } catch (Exception e) {
            throw new AuthenticationException(
                    "Invalid or expired token. Please log in again.",
                    "TOKEN_INVALID");
        }

        Admin admin = adminRepository.findByEmail(email)
                .orElseThrow(() -> new NotFoundException(
                        "Admin account not found. It may have been deleted.",
                        "ADMIN_NOT_FOUND"));

        return AdminResponse.fromEntity(admin);
    }

    public AdminResponse getAdminById(UUID adminId) {
        Admin admin = adminRepository.findById(adminId)
                .orElseThrow(() -> new NotFoundException(
                        "Admin not found with the specified ID.",
                        "ADMIN_NOT_FOUND"));
        return AdminResponse.fromEntity(admin);
    }

    public Admin createAdmin(String name, String email, String password) {
        if (adminRepository.existsByEmail(email)) {
            throw new AuthenticationException(
                    "An account with this email already exists.",
                    "EMAIL_EXISTS");
        }

        Admin admin = new Admin();
        admin.setName(name);
        admin.setEmail(email);
        admin.setPassword(passwordEncoder.encode(password));
        return adminRepository.save(admin);
    }
}
