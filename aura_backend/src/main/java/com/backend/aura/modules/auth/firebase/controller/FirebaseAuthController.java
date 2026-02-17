package com.backend.aura.modules.auth.firebase.controller;

import com.backend.aura.modules.auth.dto.LoginRequest;
import com.backend.aura.modules.auth.dto.LoginResponse;
import com.backend.aura.modules.auth.firebase.context.AuthenticatedUserContext;
import com.backend.aura.modules.user.dto.response.UserResponse;
import com.backend.aura.modules.user.model.User;
import com.backend.aura.modules.user.model.enums.AccountStatus;
import com.backend.aura.modules.user.service.UserService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class FirebaseAuthController {

    private static final Logger log = LoggerFactory.getLogger(FirebaseAuthController.class);

    private final UserService userService;

    public FirebaseAuthController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/me")
    public ResponseEntity<UserResponse> me(
            @RequestAttribute(name = "AUTH_CONTEXT", required = false) AuthenticatedUserContext authContext) {

        log.debug("------------------------------------------------------------");
        log.debug("AUTH_CTRL - GET /api/auth/me | authContext: {}",
                authContext != null ? authContext.getUid() : "null");

        if (authContext == null) {
            log.debug("AUTH_CTRL - /me RESPONSE: 401 No auth context");
            log.debug("------------------------------------------------------------");
            return ResponseEntity.status(401).build();
        }

        UserResponse user = userService.getUserDtoByUidAndContext(
                authContext.getUid(),
                authContext.getPhone(),
                authContext.getEmail());

        if (user == null) {
            log.debug("AUTH_CTRL - /me RESPONSE: 404 User not found | uid: {} | phone: {} | email: {}",
                    authContext.getUid(), authContext.getPhone(), authContext.getEmail());
            log.debug("------------------------------------------------------------");
            return ResponseEntity.notFound().build();
        }

        log.debug("AUTH_CTRL - /me RESPONSE: 200 OK | uid: {} | username: {} | profileCompleted: {}",
                user.getUid(), user.getUsername(), user.isProfileCompleted());
        log.debug("------------------------------------------------------------");
        return ResponseEntity.ok(user);
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {

        log.debug("------------------------------------------------------------");
        log.debug("AUTH_CTRL - POST /api/auth/login | identifier: {}", request.getIdentifier());

        if (request.getIdentifier() == null || request.getIdentifier().isEmpty()) {
            log.debug("AUTH_CTRL - /login RESPONSE: 400 Missing identifier");
            log.debug("------------------------------------------------------------");
            return ResponseEntity.badRequest().body(Map.of("error", "Email, username or phone is required"));
        }

        if (request.getPassword() == null || request.getPassword().isEmpty()) {
            log.debug("AUTH_CTRL - /login RESPONSE: 400 Missing password");
            log.debug("------------------------------------------------------------");
            return ResponseEntity.badRequest().body(Map.of("error", "Password is required"));
        }

        User user = userService.findByIdentifier(request.getIdentifier().trim());

        if (user == null) {
            log.debug("AUTH_CTRL - /login RESPONSE: 401 No account found for: {}", request.getIdentifier());
            log.debug("------------------------------------------------------------");
            return ResponseEntity.status(401).body(Map.of("error", "No account found with this identifier"));
        }

        log.debug("AUTH_CTRL - /login found user | uid: {} | status: {} | emailPasswordLinked: {}",
                user.getUid(), user.getAccountStatus(), user.isEmailPasswordLinked());

        if (user.getAccountStatus() != AccountStatus.ACTIVE) {
            log.debug("AUTH_CTRL - /login RESPONSE: 403 Account not active");
            log.debug("------------------------------------------------------------");
            return ResponseEntity.status(403).body(Map.of("error", "Account is not active"));
        }

        if (!user.isEmailPasswordLinked()) {
            log.debug("AUTH_CTRL - /login RESPONSE: 401 Password login not enabled");
            log.debug("------------------------------------------------------------");
            return ResponseEntity.status(401)
                    .body(Map.of("error", "Password login not enabled. Please use Google or Phone login"));
        }

        if (!userService.validatePassword(user, request.getPassword())) {
            log.debug("AUTH_CTRL - /login RESPONSE: 401 Incorrect password");
            log.debug("------------------------------------------------------------");
            return ResponseEntity.status(401).body(Map.of("error", "Incorrect password"));
        }

        if (user.getEmail() == null || user.getEmail().isEmpty()) {
            log.debug("AUTH_CTRL - /login RESPONSE: 401 No email linked");
            log.debug("------------------------------------------------------------");
            return ResponseEntity.status(401).body(Map.of("error", "No email linked to this account"));
        }

        LoginResponse response = new LoginResponse(
                user.getEmail(),
                userService.mapUserToResponse(user));

        log.debug("AUTH_CTRL - /login RESPONSE: 200 OK | email: {}", user.getEmail());
        log.debug("------------------------------------------------------------");
        return ResponseEntity.ok(response);
    }
}
