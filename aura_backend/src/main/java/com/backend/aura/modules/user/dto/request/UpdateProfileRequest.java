package com.backend.aura.modules.user.dto.request;

import lombok.Data;

@Data
public class UpdateProfileRequest {

    private String uid;
    private String name;
    private String username;
    private String email;
    private String phone;
    private String gender;
    private String dob;
    private String bio;
    private String profileImageUrl;
    private String password;
    private Boolean isPrivate;
}
