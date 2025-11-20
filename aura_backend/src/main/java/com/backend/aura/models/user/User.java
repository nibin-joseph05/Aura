package com.backend.aura.models.user;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;

import java.util.Date;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {

    @Id
    private String uid;
    
    private String phone;             
    private String email;             
    private boolean phoneVerified;    
    private boolean emailVerified;    
    private String signupMethod;      

    private boolean googleLinked;         
    private boolean emailPasswordLinked;
    
    private String name;
    private String username;
    private String profileImageUrl;
    private String gender;
    private String dob;

    private boolean profileCompleted;  
    private Date createdAt;
    private Date updatedAt;
}
