package com.backend.aura.modules.auth.admin.controller;

import com.backend.aura.modules.admin.model.Admin;
import com.backend.aura.modules.auth.admin.dto.request.AdminLoginRequest;
import com.backend.aura.modules.auth.admin.dto.request.AdminRegisterRequest;
import com.backend.aura.modules.auth.admin.dto.response.AdminLoginResponse;
import com.backend.aura.modules.auth.admin.dto.response.AdminResponse;
import com.backend.aura.modules.auth.admin.service.AdminAuthService;
import com.backend.aura.modules.common.dto.ErrorResponse;
import com.backend.aura.modules.common.exception.AuthenticationException;
import com.backend.aura.modules.common.exception.NotFoundException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin")
public class AdminAuthController {

    private final AdminAuthService adminAuthService;

    public AdminAuthController(AdminAuthService adminAuthService) {
        this.adminAuthService = adminAuthService;
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody AdminLoginRequest request) {
        try {
            AdminLoginResponse response = adminAuthService.login(request);
            return ResponseEntity.ok(response);
        } catch (AuthenticationException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(new ErrorResponse(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("Something went wrong. Please try again later."));
        }
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody AdminRegisterRequest request) {
        try {
            if (request.getName() == null || request.getName().isBlank()) {
                return ResponseEntity.badRequest()
                        .body(new ErrorResponse("Name is required"));
            }
            if (request.getEmail() == null || request.getEmail().isBlank()) {
                return ResponseEntity.badRequest()
                        .body(new ErrorResponse("Email is required"));
            }
            if (request.getPassword() == null || request.getPassword().length() < 6) {
                return ResponseEntity.badRequest()
                        .body(new ErrorResponse("Password must be at least 6 characters"));
            }

            Admin admin = adminAuthService.createAdmin(
                    request.getName(),
                    request.getEmail(),
                    request.getPassword());
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(AdminResponse.fromEntity(admin));
        } catch (AuthenticationException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body(new ErrorResponse(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("Something went wrong. Please try again later."));
        }
    }

    @GetMapping("/current")
    public ResponseEntity<?> getCurrentAdmin(
            @RequestHeader(value = "Authorization", required = false) String authHeader) {
        try {
            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(new ErrorResponse("Authentication required. Please log in."));
            }

            String token = authHeader.replace("Bearer ", "");
            AdminResponse response = adminAuthService.getCurrentAdmin(token);
            return ResponseEntity.ok(response);
        } catch (AuthenticationException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(new ErrorResponse(e.getMessage()));
        } catch (NotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("Something went wrong. Please try again later."));
        }
    }
}
