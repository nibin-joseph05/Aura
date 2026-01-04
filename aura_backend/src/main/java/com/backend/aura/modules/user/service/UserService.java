package com.backend.aura.modules.user.service;

import com.backend.aura.modules.user.dto.request.UpdateProfileRequest;
import com.backend.aura.modules.user.dto.response.UserResponse;
import com.backend.aura.modules.user.model.User;
import com.backend.aura.modules.user.model.enums.AccountStatus;
import com.backend.aura.modules.user.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.util.Date;

@Service
public class UserService {

    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public User saveUser(User user) {
        user.setUpdatedAt(new Date());
        return userRepository.save(user);
    }

    public UserResponse getUserDtoByUid(String uid) {
        User user = userRepository.findById(uid).orElse(null);
        return user == null ? null : mapToUserResponse(user);
    }

    public User createOrUpdateUser(User user) {
        User existingUser = userRepository.findById(user.getUid()).orElse(null);

        if (existingUser == null) {
            user.setCreatedAt(new Date());
            user.setAccountStatus(AccountStatus.ACTIVE);
            user.setProfileCompleted(false);
            return userRepository.save(user);
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

            if (userRepository.existsByUsername(dto.getUsername())) {
                throw new RuntimeException("Username already taken");
            }

            user.setUsername(dto.getUsername());
        }

        user.setName(dto.getName());
        user.setGender(dto.getGender());
        user.setDob(dto.getDob());
        user.setProfileImageUrl(dto.getProfileImageUrl());
        user.setProfileCompleted(true);
        user.setUpdatedAt(new Date());

        return mapToUserResponse(userRepository.save(user));
    }


    public boolean isAccountActive(String uid) {
        User user = getUserByUid(uid);
        return user != null && user.getAccountStatus() == AccountStatus.ACTIVE;
    }

    private User getUserByUid(String uid) {
        return userRepository.findById(uid).orElse(null);
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
                user.getProfileImageUrl(),
                user.getGender(),
                user.getDob(),
                user.isProfileCompleted(),
                user.getAccountStatus(),
                user.getCreatedAt(),
                user.getLastLoginAt()
        );
    }

}
