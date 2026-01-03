package com.backend.aura.modules.user.controller;

import com.backend.aura.modules.user.dto.request.UpdateProfileRequest;
import com.backend.aura.modules.user.dto.response.UserResponse;
import com.backend.aura.modules.user.dto.response.UsernameAvailabilityResponse;
import com.backend.aura.modules.user.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/user")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
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
            @RequestParam String username) {

        boolean available = userService.isUsernameAvailable(username);
        return ResponseEntity.ok(
                new UsernameAvailabilityResponse(available)
        );
    }

    @PutMapping("/profile")
    public ResponseEntity<UserResponse> updateProfile(
            @RequestBody UpdateProfileRequest dto) {

        return ResponseEntity.ok(userService.updateProfile(dto));
    }
}
