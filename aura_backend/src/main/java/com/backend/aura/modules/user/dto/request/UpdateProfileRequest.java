package com.backend.aura.modules.user.dto.request;

import lombok.Data;

@Data
public class UpdateProfileRequest {

    private String uid;
    private String name;
    private String username;
    private String gender;
    private String dob;
    private String profileImageUrl;
}
