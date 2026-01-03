package com.backend.aura.modules.auth.firebase.context;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class AuthenticatedUserContext {

    private String uid;
    private String email;
    private String phone;
    private String provider;
}
