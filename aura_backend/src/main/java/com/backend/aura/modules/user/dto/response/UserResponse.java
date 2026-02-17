package com.backend.aura.modules.user.dto.response;

import com.backend.aura.modules.user.model.enums.AccountStatus;
import com.backend.aura.modules.user.model.enums.SignupMethod;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.util.Date;

@Data
@AllArgsConstructor
@Builder
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
    private String bio;

    private boolean profileCompleted;
    private boolean isPrivate;
    private AccountStatus accountStatus;

    private Date createdAt;
    private Date lastLoginAt;

    private long followersCount;
    private long followingCount;
    private long postsCount;
}
