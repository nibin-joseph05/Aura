package com.backend.aura.modules.user.model;

import com.backend.aura.modules.user.model.enums.AccountStatus;
import com.backend.aura.modules.user.model.enums.SignupMethod;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;

@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {

    @Id
    private String uid;

    @Column(unique = true)
    private String phone;

    @Column(unique = true)
    private String email;

    private boolean phoneVerified;
    private boolean emailVerified;

    @Enumerated(EnumType.STRING)
    private SignupMethod signupMethod;

    private boolean googleLinked;
    private boolean emailPasswordLinked;
    private boolean phoneLinked;

    private String name;

    @Column(unique = true)
    private String username;

    private String profileImageUrl;
    private String gender;
    private String dob;

    private boolean profileCompleted;

    @Column(length = 200)
    private String bio;

    private boolean isPrivate;

    @Column(length = 512)
    private String fcmToken;

    private String password;

    @Enumerated(EnumType.STRING)
    private AccountStatus accountStatus;

    @Temporal(TemporalType.TIMESTAMP)
    private Date createdAt;

    @Temporal(TemporalType.TIMESTAMP)
    private Date updatedAt;

    @Temporal(TemporalType.TIMESTAMP)
    private Date lastLoginAt;

}
