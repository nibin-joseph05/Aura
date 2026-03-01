package com.backend.aura.modules.user.controller;

import com.backend.aura.modules.auth.firebase.context.AuthenticatedUserContext;
import com.backend.aura.modules.common.dto.ErrorResponse;
import com.backend.aura.modules.user.dto.request.UpdatePasswordRequest;
import com.backend.aura.modules.user.dto.request.UpdateProfileRequest;
import com.backend.aura.modules.user.dto.response.UserResponse;
import com.backend.aura.modules.user.dto.response.UsernameAvailabilityResponse;
import com.backend.aura.modules.user.service.UserService;
import com.backend.aura.modules.user.model.User;
import com.backend.aura.modules.user.repository.UserRepository;
import com.backend.aura.modules.notification.model.Notification;
import com.backend.aura.modules.notification.repository.NotificationRepository;
import com.backend.aura.modules.notification.service.PushNotificationService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/user")
public class UserController {

    private static final Logger log = LoggerFactory.getLogger(UserController.class);

    private final UserService userService;
    private final NotificationRepository notificationRepository;
    private final PushNotificationService pushNotificationService;
    private final UserRepository userRepository;

    public UserController(UserService userService, NotificationRepository notificationRepository,
            PushNotificationService pushNotificationService, UserRepository userRepository) {
        this.userService = userService;
        this.notificationRepository = notificationRepository;
        this.pushNotificationService = pushNotificationService;
        this.userRepository = userRepository;
    }

    @GetMapping("/me")
    public ResponseEntity<UserResponse> getCurrentUser(
            @RequestAttribute(name = "AUTH_CONTEXT", required = false) AuthenticatedUserContext authContext) {

        log.debug("------------------------------------------------------------");
        log.debug("USER_CTRL - GET /api/user/me | authContext: {}",
                authContext != null ? authContext.getUid() : "null");

        if (authContext == null) {
            log.debug("USER_CTRL - GET /me RESPONSE: 401 Unauthorized");
            log.debug("------------------------------------------------------------");
            return ResponseEntity.status(401).build();
        }

        UserResponse user = userService.getUserDtoByUid(authContext.getUid());

        if (user == null) {
            log.debug("USER_CTRL - GET /me RESPONSE: 404 Not Found for uid: {}", authContext.getUid());
            log.debug("------------------------------------------------------------");
            return ResponseEntity.notFound().build();
        }

        log.debug("USER_CTRL - GET /me RESPONSE: 200 OK | uid: {} | profileCompleted: {} | username: {}",
                user.getUid(), user.isProfileCompleted(), user.getUsername());
        log.debug("------------------------------------------------------------");
        return ResponseEntity.ok(user);
    }

    @GetMapping("/{uid}")
    public ResponseEntity<UserResponse> getUser(@PathVariable String uid) {

        log.debug("------------------------------------------------------------");
        log.debug("USER_CTRL - GET /api/user/{} | Fetching user", uid);

        UserResponse user = userService.getUserDtoByUid(uid);

        if (user == null) {
            log.debug("USER_CTRL - GET /api/user/{} RESPONSE: 404 Not Found", uid);
            log.debug("------------------------------------------------------------");
            return ResponseEntity.notFound().build();
        }

        log.debug("USER_CTRL - GET /api/user/{} RESPONSE: 200 OK | username: {} | profileCompleted: {}",
                uid, user.getUsername(), user.isProfileCompleted());
        log.debug("------------------------------------------------------------");
        return ResponseEntity.ok(user);
    }

    @GetMapping("/username-available")
    public ResponseEntity<UsernameAvailabilityResponse> isUsernameAvailable(
            @RequestParam String username,
            @RequestParam String uid) {

        log.debug("------------------------------------------------------------");
        log.debug("USER_CTRL - GET /username-available | username: {} | uid: {}", username, uid);

        boolean available = userService.isUsernameAvailable(username, uid);

        log.debug("USER_CTRL - /username-available RESPONSE: available={}", available);
        log.debug("------------------------------------------------------------");

        return ResponseEntity.ok(
                new UsernameAvailabilityResponse(available));
    }

    @PutMapping("/profile")
    public ResponseEntity<?> updateProfile(
            @RequestBody UpdateProfileRequest dto) {

        log.debug("------------------------------------------------------------");
        log.debug(
                "USER_CTRL - PUT /profile | uid: {} | name: {} | username: {} | email: {} | phone: {} | gender: {} | dob: {} | hasImage: {} | hasPassword: {}",
                dto.getUid(), dto.getName(), dto.getUsername(), dto.getEmail(), dto.getPhone(),
                dto.getGender(), dto.getDob(),
                dto.getProfileImageUrl() != null, dto.getPassword() != null);

        try {
            UserResponse result = userService.updateProfile(dto);

            User user = userRepository.findById(dto.getUid()).orElse(null);

            log.debug("USER_CTRL - PUT /profile | Checking if user exists. Found: {}", user != null);
            if (user != null) {
                log.debug("USER_CTRL - PUT /profile | User FCM Token: {}", user.getFcmToken());
            }

            if (user != null && user.getFcmToken() != null && !user.getFcmToken().isEmpty()) {
                Notification notif = Notification.builder()
                        .title("Profile Updated")
                        .body("Your profile has been successfully updated.")
                        .type(Notification.NotificationType.ACCOUNT_ALERT)
                        .targetUserId(user.getUid())
                        .isBroadcast(false)
                        .build();
                notificationRepository.save(notif);

                log.debug("USER_CTRL - PUT /profile | Dispatching Push Notification to FCM token...");
                boolean pushSuccess = pushNotificationService.sendToUser(user.getFcmToken(), notif.getTitle(),
                        notif.getBody(), null);
                log.debug("USER_CTRL - PUT /profile | Push Notification Dispatch Success: {}", pushSuccess);
            }

            log.debug("USER_CTRL - PUT /profile RESPONSE: 200 OK | profileCompleted: {}", result.isProfileCompleted());
            log.debug("------------------------------------------------------------");
            return ResponseEntity.ok(result);
        } catch (RuntimeException e) {
            log.debug("USER_CTRL - PUT /profile RESPONSE: 400 Error | message: {}", e.getMessage());
            log.debug("------------------------------------------------------------");
            return ResponseEntity.badRequest().body(new ErrorResponse(e.getMessage()));
        }
    }

    @PostMapping("/password/change")
    public ResponseEntity<?> changePassword(@RequestBody UpdatePasswordRequest request) {

        log.debug("------------------------------------------------------------");
        log.debug("USER_CTRL - POST /password/change | uid: {}", request.getUid());

        if (request.getUid() == null || request.getUid().isEmpty()) {
            log.debug("USER_CTRL - /password/change RESPONSE: 400 Missing uid");
            log.debug("------------------------------------------------------------");
            return ResponseEntity.badRequest().body(new ErrorResponse("Missing user id"));
        }

        try {
            userService.updatePassword(request.getUid(), request.getCurrentPassword(), request.getNewPassword());

            User user = userRepository.findById(request.getUid()).orElse(null);
            if (user != null && user.getFcmToken() != null && !user.getFcmToken().isEmpty()) {
                Notification notif = Notification.builder()
                        .title("Password Changed")
                        .body("Your account password has been updated successfully.")
                        .type(Notification.NotificationType.AUTH_ALERT)
                        .targetUserId(user.getUid())
                        .isBroadcast(false)
                        .build();
                notificationRepository.save(notif);
                pushNotificationService.sendToUser(user.getFcmToken(), notif.getTitle(), notif.getBody(), null);
            }

            log.debug("USER_CTRL - /password/change RESPONSE: 200 OK");
            log.debug("------------------------------------------------------------");
            return ResponseEntity.ok(Map.of("message", "Password updated successfully"));
        } catch (RuntimeException e) {
            log.debug("USER_CTRL - /password/change RESPONSE: 400 Error | message: {}", e.getMessage());
            log.debug("------------------------------------------------------------");
            return ResponseEntity.badRequest().body(new ErrorResponse(e.getMessage()));
        }
    }

    @PostMapping("/fcm-token")
    public ResponseEntity<Void> updateFcmToken(@RequestBody Map<String, String> body) {
        log.debug("USER_CTRL - POST /fcm-token | uid: {}", body.get("uid"));
        userService.updateFcmToken(body.get("uid"), body.get("token"));
        return ResponseEntity.ok().build();
    }
}
