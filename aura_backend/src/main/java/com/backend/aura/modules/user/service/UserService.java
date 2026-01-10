package com.backend.aura.modules.user.service;

import com.backend.aura.modules.user.dto.request.UpdateProfileRequest;
import com.backend.aura.modules.user.dto.response.UserResponse;
import com.backend.aura.modules.user.model.User;
import com.backend.aura.modules.user.model.enums.AccountStatus;
import com.backend.aura.modules.user.repository.UserRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Date;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final BCryptPasswordEncoder passwordEncoder;

    @Value("${server.address:localhost}")
    private String serverAddress;

    @Value("${server.port:8080}")
    private String serverPort;

    public UserService(UserRepository userRepository, BCryptPasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public User saveUser(User user) {
        user.setUpdatedAt(new Date());
        return userRepository.save(user);
    }

    public UserResponse getUserDtoByUid(String uid) {
        return getUserDtoByUidAndContext(uid, null, null);
    }

    public UserResponse getUserDtoByUidAndContext(String uid, String phone, String email) {
        User user = userRepository.findById(uid).orElse(null);
        if (user == null && phone != null && !phone.isEmpty()) {
            user = userRepository.findByPhone(phone).orElse(null);
        }
        if (user == null && email != null && !email.isEmpty()) {
            user = userRepository.findByEmail(email).orElse(null);
        }
        return user == null ? null : mapToUserResponse(user);
    }

    public User createOrUpdateUser(User user) {
        User existingUser = userRepository.findById(user.getUid()).orElse(null);

        if (existingUser == null) {
            if (user.getPhone() != null && !user.getPhone().isEmpty()) {
                existingUser = userRepository.findByPhone(user.getPhone()).orElse(null);
            }
            if (existingUser == null && user.getEmail() != null && !user.getEmail().isEmpty()) {
                existingUser = userRepository.findByEmail(user.getEmail()).orElse(null);
            }
        }

        if (existingUser == null) {
            user.setCreatedAt(new Date());
            user.setAccountStatus(AccountStatus.ACTIVE);
            user.setProfileCompleted(false);
            return userRepository.save(user);
        }

        if (user.getEmail() != null && !user.getEmail().isEmpty()) {
            existingUser.setEmail(user.getEmail());
            existingUser.setEmailVerified(user.isEmailVerified());
        }

        if (user.getPhone() != null && !user.getPhone().isEmpty()) {
            existingUser.setPhone(user.getPhone());
            existingUser.setPhoneVerified(user.isPhoneVerified());
        }

        if (user.isGoogleLinked()) {
            existingUser.setGoogleLinked(true);
        }
        if (user.isPhoneLinked()) {
            existingUser.setPhoneLinked(true);
        }
        if (user.isEmailPasswordLinked()) {
            existingUser.setEmailPasswordLinked(true);
        }

        existingUser.setLastLoginAt(new Date());
        existingUser.setUpdatedAt(new Date());

        return userRepository.save(existingUser);
    }

    public boolean isUsernameAvailable(String username, String uid) {
        return !userRepository.existsByUsernameAndUidNot(username, uid);
    }

    public UserResponse updateProfile(UpdateProfileRequest dto) {

        User user = getUserByUid(dto.getUid());

        if (user == null) {
            throw new RuntimeException("User not found");
        }

        if (dto.getUsername() != null &&
                !dto.getUsername().equals(user.getUsername())) {

            if (!dto.getUsername().matches("^[a-zA-Z_]+$")) {
                throw new RuntimeException("Username can only contain letters and underscores");
            }

            if (userRepository.existsByUsername(dto.getUsername())) {
                throw new RuntimeException("Username already taken");
            }

            user.setUsername(dto.getUsername());
        }

        if (dto.getName() != null && !dto.getName().isEmpty()) {
            user.setName(dto.getName());
        }

        if (dto.getEmail() != null && !dto.getEmail().isEmpty()) {
            if (user.getEmail() == null || user.getEmail().isEmpty()) {
                if (userRepository.existsByEmailAndUidNot(dto.getEmail(), dto.getUid())) {
                    throw new RuntimeException("Email already in use by another account");
                }
                user.setEmail(dto.getEmail());
            }
        }

        if (dto.getPhone() != null && !dto.getPhone().isEmpty()) {
            if (user.getPhone() == null || user.getPhone().isEmpty()) {
                if (userRepository.existsByPhoneAndUidNot(dto.getPhone(), dto.getUid())) {
                    throw new RuntimeException("Phone number already in use by another account");
                }
                user.setPhone(dto.getPhone());
                user.setPhoneLinked(true);
            }
        }

        if (dto.getGender() != null && !dto.getGender().isEmpty()) {
            user.setGender(dto.getGender());
        }

        if (dto.getDob() != null && !dto.getDob().isEmpty()) {
            user.setDob(dto.getDob());
        }

        if (dto.getProfileImageUrl() != null && !dto.getProfileImageUrl().isEmpty()) {
            user.setProfileImageUrl(dto.getProfileImageUrl());
        }

        if (dto.getPassword() != null && !dto.getPassword().isEmpty()) {
            user.setPassword(passwordEncoder.encode(dto.getPassword()));
            user.setEmailPasswordLinked(true);
        }

        boolean isProfileComplete = user.getName() != null && !user.getName().isEmpty() &&
                user.getUsername() != null && !user.getUsername().isEmpty() &&
                user.getGender() != null && !user.getGender().isEmpty() &&
                user.getDob() != null && !user.getDob().isEmpty();

        user.setProfileCompleted(isProfileComplete);
        user.setUpdatedAt(new Date());

        User savedUser = userRepository.save(user);
        return mapToUserResponse(savedUser);
    }

    public boolean isAccountActive(String uid) {
        User user = getUserByUid(uid);
        return user != null && user.getAccountStatus() == AccountStatus.ACTIVE;
    }

    private User getUserByUid(String uid) {
        return userRepository.findById(uid).orElse(null);
    }

    private String buildFullImageUrl(String relativePath) {
        if (relativePath == null || relativePath.isEmpty()) {
            return null;
        }
        if (relativePath.startsWith("http")) {
            return relativePath;
        }
        return "http://" + serverAddress + ":" + serverPort + "/uploads/" + relativePath;
    }

    private UserResponse mapToUserResponse(User user) {
        return new UserResponse(
                user.getUid(),
                user.getPhone(),
                user.getEmail(),
                user.isPhoneVerified(),
                user.isEmailVerified(),
                user.getSignupMethod(),
                user.getName(),
                user.getUsername(),
                buildFullImageUrl(user.getProfileImageUrl()),
                user.getGender(),
                user.getDob(),
                user.isProfileCompleted(),
                user.getAccountStatus(),
                user.getCreatedAt(),
                user.getLastLoginAt());
    }
}