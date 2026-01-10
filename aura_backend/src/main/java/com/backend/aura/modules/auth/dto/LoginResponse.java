package com.backend.aura.modules.auth.dto;

import com.backend.aura.modules.user.dto.response.UserResponse;

public class LoginResponse {

    private String email;
    private UserResponse user;

    public LoginResponse() {
    }

    public LoginResponse(String email, UserResponse user) {
        this.email = email;
        this.user = user;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public UserResponse getUser() {
        return user;
    }

    public void setUser(UserResponse user) {
        this.user = user;
    }
}
