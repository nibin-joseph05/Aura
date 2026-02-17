package com.backend.aura.modules.user.controller;

import com.backend.aura.modules.auth.firebase.context.AuthenticatedUserContext;
import com.backend.aura.modules.common.dto.ErrorResponse;
import com.backend.aura.modules.user.dto.request.UpdateProfileRequest;
import com.backend.aura.modules.user.dto.response.UserResponse;
import com.backend.aura.modules.user.dto.response.UsernameAvailabilityResponse;
import com.backend.aura.modules.user.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/user")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/me")
    public ResponseEntity<UserResponse> getCurrentUser(
            @RequestAttribute(name = "AUTH_CONTEXT", required = false) AuthenticatedUserContext authContext) {

        if (authContext == null) {
            return ResponseEntity.status(401).build();
        }

        UserResponse user = userService.getUserDtoByUid(authContext.getUid());

        if (user == null) {
            return ResponseEntity.notFound().build();
        }

        return ResponseEntity.ok(user);
    }

    @GetMapping("/{uid}")
    public ResponseEntity<UserResponse> getUser(@PathVariable String uid) {

        UserResponse user = userService.getUserDtoByUid(uid);

        if (user == null) {
            return ResponseEntity.notFound().build();
        }

        return ResponseEntity.ok(user);
    }

    @GetMapping("/username-available")
    public ResponseEntity<UsernameAvailabilityResponse> isUsernameAvailable(
            @RequestParam String username,
            @RequestParam String uid) {

        boolean available = userService.isUsernameAvailable(username, uid);
        return ResponseEntity.ok(
                new UsernameAvailabilityResponse(available));
    }

    @PutMapping("/profile")
    public ResponseEntity<?> updateProfile(
            @RequestBody UpdateProfileRequest dto) {
        try {
            return ResponseEntity.ok(userService.updateProfile(dto));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(new ErrorResponse(e.getMessage()));
        }
    }

    @PostMapping("/fcm-token")
    public ResponseEntity<Void> updateFcmToken(@RequestBody Map<String, String> body) {
        userService.updateFcmToken(body.get("uid"), body.get("token"));
        return ResponseEntity.ok().build();
    }
}
