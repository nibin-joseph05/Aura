package com.backend.aura.modules.auth.firebase.controller;

import com.backend.aura.modules.auth.dto.LoginRequest;
import com.backend.aura.modules.auth.dto.LoginResponse;
import com.backend.aura.modules.auth.firebase.context.AuthenticatedUserContext;
import com.backend.aura.modules.user.dto.response.UserResponse;
import com.backend.aura.modules.user.model.User;
import com.backend.aura.modules.user.model.enums.AccountStatus;
import com.backend.aura.modules.user.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class FirebaseAuthController {

    private final UserService userService;

    public FirebaseAuthController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/me")
    public ResponseEntity<UserResponse> me(
            @RequestAttribute(name = "AUTH_CONTEXT", required = false) AuthenticatedUserContext authContext) {
        if (authContext == null) {
            return ResponseEntity.status(401).build();
        }
        UserResponse user = userService.getUserDtoByUidAndContext(
                authContext.getUid(),
                authContext.getPhone(),
                authContext.getEmail());
        if (user == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(user);
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        if (request.getIdentifier() == null || request.getIdentifier().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Email, username or phone is required"));
        }

        if (request.getPassword() == null || request.getPassword().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Password is required"));
        }

        User user = userService.findByIdentifier(request.getIdentifier().trim());

        if (user == null) {
            return ResponseEntity.status(401).body(Map.of("error", "No account found with this identifier"));
        }

        if (user.getAccountStatus() != AccountStatus.ACTIVE) {
            return ResponseEntity.status(403).body(Map.of("error", "Account is not active"));
        }

        if (!user.isEmailPasswordLinked()) {
            return ResponseEntity.status(401)
                    .body(Map.of("error", "Password login not enabled. Please use Google or Phone login"));
        }

        if (!userService.validatePassword(user, request.getPassword())) {
            return ResponseEntity.status(401).body(Map.of("error", "Incorrect password"));
        }

        if (user.getEmail() == null || user.getEmail().isEmpty()) {
            return ResponseEntity.status(401).body(Map.of("error", "No email linked to this account"));
        }

        LoginResponse response = new LoginResponse(
                user.getEmail(),
                userService.mapUserToResponse(user));

        return ResponseEntity.ok(response);
    }
}
