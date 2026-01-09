package com.backend.aura.modules.auth.firebase.controller;

import com.backend.aura.modules.auth.firebase.context.AuthenticatedUserContext;
import com.backend.aura.modules.user.dto.response.UserResponse;
import com.backend.aura.modules.user.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

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
}
