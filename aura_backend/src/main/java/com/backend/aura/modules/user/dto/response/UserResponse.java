package com.backend.aura.modules.user.dto.response;

import com.backend.aura.modules.user.model.enums.AccountStatus;
import com.backend.aura.modules.user.model.enums.SignupMethod;
import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.Date;

@Data
@AllArgsConstructor
public class UserResponse {

    private String uid;
    private String phone;
    private String email;

    private boolean phoneVerified;
    private boolean emailVerified;

    private SignupMethod signupMethod;

    private String name;
    private String username;
    private String profileImageUrl;
    private String gender;
    private String dob;

    private boolean profileCompleted;
    private AccountStatus accountStatus;

    private Date createdAt;
    private Date lastLoginAt;
}
