package com.backend.aura.modules.auth.firebase.controller;

import com.backend.aura.modules.auth.firebase.context.AuthenticatedUserContext;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class FirebaseAuthController {

    @GetMapping("/me")
    public ResponseEntity<AuthenticatedUserContext> me(
            @RequestAttribute(name = "AUTH_CONTEXT", required = false)
            AuthenticatedUserContext authContext
    ) {
        if (authContext == null) {
            return ResponseEntity.status(401).build();
        }
        return ResponseEntity.ok(authContext);
    }
}
