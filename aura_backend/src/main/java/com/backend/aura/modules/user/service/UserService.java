package com.backend.aura.modules.user.service;

import com.backend.aura.modules.auth.dto.RegisterRequest;
import com.backend.aura.modules.mail.service.EmailService;
import com.backend.aura.modules.messaging.model.FollowRelationship;
import com.backend.aura.modules.messaging.repository.FollowRelationshipRepository;
import com.backend.aura.modules.user.dto.request.UpdateProfileRequest;
import com.backend.aura.modules.user.dto.response.UserResponse;
import com.backend.aura.modules.user.model.User;
import com.backend.aura.modules.user.model.enums.AccountStatus;
import com.backend.aura.modules.user.model.enums.SignupMethod;
import com.backend.aura.modules.user.repository.UserRepository;
import com.backend.aura.modules.wellness.repository.WellnessUpdateRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Date;

@Service
public class UserService {

    private static final Logger log = LoggerFactory.getLogger(UserService.class);

    private final UserRepository userRepository;
    private final BCryptPasswordEncoder passwordEncoder;
    private final EmailService emailService;
    private final FollowRelationshipRepository followRepo;
    private final WellnessUpdateRepository wellnessRepo;

    public UserService(UserRepository userRepository, BCryptPasswordEncoder passwordEncoder,
            EmailService emailService, FollowRelationshipRepository followRepo,
            WellnessUpdateRepository wellnessRepo) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.emailService = emailService;
        this.followRepo = followRepo;
        this.wellnessRepo = wellnessRepo;
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
        log.debug("USER_SVC - createOrUpdateUser | uid: {} | email: {} | phone: {}", user.getUid(), user.getEmail(),
                user.getPhone());
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
            log.debug("USER_SVC - Creating NEW user | uid: {}", user.getUid());
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

        log.debug("USER_SVC - Updating EXISTING user | uid: {} | profileCompleted: {}", existingUser.getUid(),
                existingUser.isProfileCompleted());
        return userRepository.save(existingUser);
    }

    public boolean isUsernameAvailable(String username, String uid) {
        boolean exists = userRepository.existsByUsernameAndUidNot(username, uid);
        log.debug("USER_SVC - isUsernameAvailable | username: {} | uid: {} | existsByOther: {} | available: {}",
                username, uid, exists, !exists);
        return !exists;
    }

    public UserResponse updateProfile(UpdateProfileRequest dto) {
        log.debug("USER_SVC - updateProfile | uid: {} | username: {} | name: {}", dto.getUid(), dto.getUsername(),
                dto.getName());

        User user = getUserByUid(dto.getUid());

        if (user == null) {
            log.debug("USER_SVC - updateProfile FAILED | User not found for uid: {}", dto.getUid());
            throw new RuntimeException("User not found");
        }

        if (dto.getUsername() != null &&
                !dto.getUsername().equals(user.getUsername())) {

            if (!dto.getUsername().matches("^[a-zA-Z_]+$")) {
                throw new RuntimeException("Username can only contain letters and underscores");
            }

            if (userRepository.existsByUsernameAndUidNot(dto.getUsername(), dto.getUid())) {
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

        if (dto.getBio() != null) {
            user.setBio(dto.getBio());
        }

        if (dto.getIsPrivate() != null) {
            user.setPrivate(dto.getIsPrivate());
        }

        boolean wasProfileComplete = user.isProfileCompleted();

        boolean isProfileComplete = user.getName() != null && !user.getName().isEmpty() &&
                user.getUsername() != null && !user.getUsername().isEmpty() &&
                user.getGender() != null && !user.getGender().isEmpty() &&
                user.getDob() != null && !user.getDob().isEmpty();

        user.setProfileCompleted(isProfileComplete);
        user.setUpdatedAt(new Date());

        User savedUser = userRepository.save(user);

        if (isProfileComplete && !wasProfileComplete && savedUser.getEmail() != null) {
            emailService.sendWelcomeEmail(savedUser.getEmail(), savedUser.getName());
        }

        return mapToUserResponse(savedUser);
    }

    public UserResponse registerUser(RegisterRequest request) {
        if (userRepository.findByEmail(request.getEmail().trim()).isPresent()) {
            throw new RuntimeException("Email already registered");
        }
        if (userRepository.findByUsername(request.getUsername().trim()).isPresent()) {
            throw new RuntimeException("Username already taken");
        }
        if (request.getPhone() != null && !request.getPhone().isEmpty()) {
            if (userRepository.findByPhone(request.getPhone().trim()).isPresent()) {
                throw new RuntimeException("Phone number already registered");
            }
        }

        User user = new User();
        user.setUid(java.util.UUID.randomUUID().toString());
        user.setName(request.getName().trim());
        user.setEmail(request.getEmail().trim());
        user.setUsername(request.getUsername().trim());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setEmailPasswordLinked(true);
        user.setSignupMethod(SignupMethod.EMAIL);
        user.setAccountStatus(AccountStatus.ACTIVE);
        user.setCreatedAt(new Date());
        user.setLastLoginAt(new Date());
        user.setUpdatedAt(new Date());

        if (request.getPhone() != null && !request.getPhone().isEmpty()) {
            user.setPhone(request.getPhone().trim());
        }
        if (request.getGender() != null && !request.getGender().isEmpty()) {
            user.setGender(request.getGender());
        }
        if (request.getDob() != null && !request.getDob().isEmpty()) {
            user.setDob(request.getDob());
        }
        if (request.getProfileImageUrl() != null && !request.getProfileImageUrl().isEmpty()) {
            user.setProfileImageUrl(request.getProfileImageUrl());
        }

        boolean profileComplete = user.getName() != null && !user.getName().isEmpty() &&
                user.getUsername() != null && !user.getUsername().isEmpty() &&
                user.getGender() != null && !user.getGender().isEmpty() &&
                user.getDob() != null && !user.getDob().isEmpty();
        user.setProfileCompleted(profileComplete);

        User saved = userRepository.save(user);

        if (saved.getEmail() != null && profileComplete) {
            emailService.sendWelcomeEmail(saved.getEmail(), saved.getName());
        }

        return mapToUserResponse(saved);
    }

    public void updateFcmToken(String uid, String token) {
        User user = getUserByUid(uid);
        if (user != null) {
            user.setFcmToken(token);
            user.setUpdatedAt(new Date());
            userRepository.save(user);
        }
    }

    public boolean isAccountActive(String uid) {
        User user = getUserByUid(uid);
        return user != null && user.getAccountStatus() == AccountStatus.ACTIVE;
    }

    private User getUserByUid(String uid) {
        return userRepository.findById(uid).orElse(null);
    }

    public User findByIdentifier(String identifier) {
        if (identifier == null || identifier.isEmpty()) {
            return null;
        }

        String trimmed = identifier.trim();

        User user = userRepository.findByEmail(trimmed).orElse(null);
        if (user != null) {
            return user;
        }

        user = userRepository.findByUsername(trimmed).orElse(null);
        if (user != null) {
            return user;
        }

        user = userRepository.findByPhone(trimmed).orElse(null);
        if (user != null) {
            return user;
        }

        if (!trimmed.startsWith("+")) {
            user = userRepository.findByPhone("+91" + trimmed).orElse(null);
            if (user != null) {
                return user;
            }
        }

        return null;
    }

    public boolean validatePassword(User user, String rawPassword) {
        if (user == null || user.getPassword() == null || rawPassword == null) {
            return false;
        }
        return passwordEncoder.matches(rawPassword, user.getPassword());
    }

    public UserResponse mapUserToResponse(User user) {
        return mapToUserResponse(user);
    }

    public UserResponse mapToUserResponse(User user) {
        long followersCount = followRepo.countByFollowingIdAndStatus(
                user.getUid(), FollowRelationship.FollowStatus.ACCEPTED);
        long followingCount = followRepo.countByFollowerIdAndStatus(
                user.getUid(), FollowRelationship.FollowStatus.ACCEPTED);
        long postsCount = wellnessRepo.countByUserId(user.getUid());

        return UserResponse.builder()
                .uid(user.getUid())
                .phone(user.getPhone())
                .email(user.getEmail())
                .phoneVerified(user.isPhoneVerified())
                .emailVerified(user.isEmailVerified())
                .signupMethod(user.getSignupMethod())
                .name(user.getName())
                .username(user.getUsername())
                .profileImageUrl(user.getProfileImageUrl())
                .gender(user.getGender())
                .dob(user.getDob())
                .bio(user.getBio())
                .profileCompleted(user.isProfileCompleted())
                .isPrivate(user.isPrivate())
                .accountStatus(user.getAccountStatus())
                .createdAt(user.getCreatedAt())
                .lastLoginAt(user.getLastLoginAt())
                .followersCount(followersCount)
                .followingCount(followingCount)
                .postsCount(postsCount)
                .build();
    }
}