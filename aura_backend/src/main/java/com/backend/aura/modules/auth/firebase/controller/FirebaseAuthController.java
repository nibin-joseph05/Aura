package com.backend.aura.modules.auth.firebase.controller;

import com.backend.aura.modules.auth.dto.LoginRequest;
import com.backend.aura.modules.auth.dto.LoginResponse;
import com.backend.aura.modules.auth.dto.RegisterRequest;
import com.backend.aura.modules.auth.firebase.context.AuthenticatedUserContext;
import com.backend.aura.modules.user.dto.response.UserResponse;
import com.backend.aura.modules.user.model.User;
import com.backend.aura.modules.user.model.enums.AccountStatus;
import com.backend.aura.modules.user.service.UserService;
import com.backend.aura.modules.auth.dto.PasswordForgotRequest;
import com.backend.aura.modules.auth.dto.PasswordResetRequest;
import com.backend.aura.modules.mail.service.EmailService;
import com.backend.aura.modules.user.service.EmailOtpStore;
import com.backend.aura.modules.notification.model.Notification;
import com.backend.aura.modules.notification.repository.NotificationRepository;
import com.backend.aura.modules.notification.service.PushNotificationService;
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
    private final EmailOtpStore otpStore;
    private final EmailService emailService;
    private final NotificationRepository notificationRepository;
    private final PushNotificationService pushNotificationService;

    public FirebaseAuthController(UserService userService, EmailOtpStore otpStore, EmailService emailService,
            NotificationRepository notificationRepository, PushNotificationService pushNotificationService) {
        this.userService = userService;
        this.otpStore = otpStore;
        this.emailService = emailService;
        this.notificationRepository = notificationRepository;
        this.pushNotificationService = pushNotificationService;
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

        boolean loginByEmail = request.getIdentifier().trim().contains("@");
        boolean loginByPhone = !loginByEmail &&
                request.getIdentifier().trim().matches("^[+]?[0-9]{7,15}$");

        if (loginByEmail && !user.isEmailVerified()) {
            log.debug("AUTH_CTRL - /login RESPONSE: 403 Email not verified | uid: {}", user.getUid());
            log.debug("------------------------------------------------------------");
            return ResponseEntity.status(403).body(Map.of(
                    "error",
                    "Your email address is not verified. Please verify your email before logging in, or log in using your username."));
        }

        if (loginByPhone && !user.isPhoneVerified()) {
            log.debug("AUTH_CTRL - /login RESPONSE: 403 Phone not verified | uid: {}", user.getUid());
            log.debug("------------------------------------------------------------");
            return ResponseEntity.status(403).body(Map.of(
                    "error",
                    "Your phone number is not verified. Please verify your phone number before logging in, or log in using your username."));
        }

        if (user.getEmail() == null || user.getEmail().isEmpty()) {
            log.debug("AUTH_CTRL - /login RESPONSE: 401 No email linked");
            log.debug("------------------------------------------------------------");
            return ResponseEntity.status(401).body(Map.of("error", "No email linked to this account"));
        }

        LoginResponse response = new LoginResponse(
                user.getEmail(),
                userService.mapUserToResponse(user));

        if (request.getFcmToken() != null && !request.getFcmToken().isEmpty()
                && !request.getFcmToken().equals(user.getFcmToken())) {
            log.debug("AUTH_CTRL - /login | Persisting new FCM Token to database...");
            user.setFcmToken(request.getFcmToken());
            userService.saveUser(user);
        }

        if (user.getFcmToken() != null && !user.getFcmToken().isEmpty()) {
            Notification notif = Notification.builder()
                    .title("New Login Detected")
                    .body("Your account was just logged into.")
                    .type(Notification.NotificationType.AUTH_ALERT)
                    .targetUserId(user.getUid())
                    .isBroadcast(false)
                    .build();
            notificationRepository.save(notif);
            pushNotificationService.sendToUser(user.getFcmToken(), notif.getTitle(), notif.getBody(), null);
        }

        log.debug("AUTH_CTRL - /login RESPONSE: 200 OK | email: {}", user.getEmail());
        log.debug("------------------------------------------------------------");
        return ResponseEntity.ok(response);
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody RegisterRequest request) {

        log.debug("------------------------------------------------------------");
        log.debug("AUTH_CTRL - POST /api/auth/register | email: {} | username: {}",
                request.getEmail(), request.getUsername());

        if (request.getEmail() == null || request.getEmail().trim().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Email is required"));
        }
        if (request.getUsername() == null || request.getUsername().trim().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Username is required"));
        }
        if (request.getPassword() == null || request.getPassword().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Password is required"));
        }
        if (request.getName() == null || request.getName().trim().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Name is required"));
        }

        try {
            UserResponse user = userService.registerUser(request);

            User savedUser = userService.findByIdentifier(request.getEmail().trim());
            if (savedUser != null && savedUser.getFcmToken() != null && !savedUser.getFcmToken().isEmpty()) {
                Notification notif = Notification.builder()
                        .title("Welcome to Aura!")
                        .body("Your account has been successfully created.")
                        .type(Notification.NotificationType.ACCOUNT_ALERT)
                        .targetUserId(savedUser.getUid())
                        .isBroadcast(false)
                        .build();
                notificationRepository.save(notif);
                pushNotificationService.sendToUser(savedUser.getFcmToken(), notif.getTitle(), notif.getBody(), null);
            }

            log.debug("AUTH_CTRL - /register RESPONSE: 200 OK | uid: {}", user.getUid());
            log.debug("------------------------------------------------------------");
            return ResponseEntity.ok(Map.of("user", user));
        } catch (RuntimeException e) {
            log.debug("AUTH_CTRL - /register RESPONSE: 400 | error: {}", e.getMessage());
            log.debug("------------------------------------------------------------");
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/password/forgot")
    public ResponseEntity<?> forgotPassword(@RequestBody PasswordForgotRequest request) {
        log.debug("------------------------------------------------------------");
        log.debug("AUTH_CTRL - POST /api/auth/password/forgot | email: {}", request.getEmail());

        if (request.getEmail() == null || request.getEmail().isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Email is required"));
        }

        User user = userService.findByIdentifier(request.getEmail().trim());
        if (user == null || user.getEmail() == null || user.getEmail().isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "No account found with this email"));
        }

        if (!user.isEmailVerified() && !request.isForce()) {
            return ResponseEntity.status(409).body(Map.of(
                    "error", "unverified_email",
                    "message", "Email is not verified. Are you sure you want to send the reset link?"));
        }

        String otp = otpStore.generateAndStore(user.getEmail().trim());
        emailService.sendPasswordResetEmail(user.getEmail().trim(), otp);

        log.debug("AUTH_CTRL - /password/forgot RESPONSE: 200 OK | email: {}", user.getEmail());
        log.debug("------------------------------------------------------------");
        return ResponseEntity.ok(Map.of("message", "Password reset email sent"));
    }

    @PostMapping("/password/reset")
    public ResponseEntity<?> resetPassword(@RequestBody PasswordResetRequest request) {
        log.debug("------------------------------------------------------------");
        log.debug("AUTH_CTRL - POST /api/auth/password/reset | email: {}", request.getEmail());

        if (request.getEmail() == null || request.getOtp() == null || request.getNewPassword() == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "Email, OTP, and new password are required"));
        }

        if (!otpStore.verify(request.getEmail().trim(), request.getOtp().trim())) {
            return ResponseEntity.badRequest().body(Map.of("error", "Invalid or expired OTP"));
        }

        try {
            userService.resetPassword(request.getEmail().trim(), request.getNewPassword());

            User user = userService.findByIdentifier(request.getEmail().trim());
            if (user != null && user.getFcmToken() != null && !user.getFcmToken().isEmpty()) {
                Notification notif = Notification.builder()
                        .title("Password Reset Successful")
                        .body("Your password has been changed.")
                        .type(Notification.NotificationType.AUTH_ALERT)
                        .targetUserId(user.getUid())
                        .isBroadcast(false)
                        .build();
                notificationRepository.save(notif);
                pushNotificationService.sendToUser(user.getFcmToken(), notif.getTitle(), notif.getBody(), null);
            }

            log.debug("AUTH_CTRL - /password/reset RESPONSE: 200 OK");
            log.debug("------------------------------------------------------------");
            return ResponseEntity.ok(Map.of("message", "Password reset successfully"));
        } catch (RuntimeException e) {
            log.debug("AUTH_CTRL - /password/reset RESPONSE: 400 | error: {}", e.getMessage());
            log.debug("------------------------------------------------------------");
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}
