package com.backend.aura.modules.user.controller;

import com.backend.aura.modules.common.dto.ErrorResponse;
import com.backend.aura.modules.mail.service.EmailService;
import com.backend.aura.modules.user.dto.response.UserResponse;
import com.backend.aura.modules.user.model.User;
import com.backend.aura.modules.user.repository.UserRepository;
import com.backend.aura.modules.user.service.EmailOtpStore;
import com.backend.aura.modules.user.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
import java.util.Map;

@RestController
@RequestMapping("/api/user/verify-email")
public class EmailVerificationController {

    private final EmailOtpStore otpStore;
    private final EmailService emailService;
    private final UserRepository userRepository;
    private final UserService userService;

    public EmailVerificationController(EmailOtpStore otpStore, EmailService emailService,
            UserRepository userRepository, UserService userService) {
        this.otpStore = otpStore;
        this.emailService = emailService;
        this.userRepository = userRepository;
        this.userService = userService;
    }

    @PostMapping("/send")
    public ResponseEntity<?> sendOtp(@RequestBody Map<String, String> body) {
        String email = body.get("email");
        if (email == null || email.isBlank()) {
            return ResponseEntity.badRequest().body(new ErrorResponse("Email is required"));
        }

        User user = userRepository.findByEmail(email.trim()).orElse(null);
        if (user == null) {
            return ResponseEntity.badRequest().body(new ErrorResponse("No account found with this email"));
        }

        if (user.isEmailVerified()) {
            return ResponseEntity.badRequest().body(new ErrorResponse("Email is already verified"));
        }

        String otp = otpStore.generateAndStore(email.trim());
        emailService.sendOtpVerification(email.trim(), otp, "Email Verification");

        return ResponseEntity.ok(Map.of("message", "OTP sent to " + email));
    }

    @PostMapping("/confirm")
    public ResponseEntity<?> confirmOtp(@RequestBody Map<String, String> body) {
        String email = body.get("email");
        String otp = body.get("otp");

        if (email == null || otp == null) {
            return ResponseEntity.badRequest().body(new ErrorResponse("Email and OTP are required"));
        }

        if (!otpStore.verify(email.trim(), otp.trim())) {
            return ResponseEntity.badRequest().body(new ErrorResponse("Invalid or expired OTP"));
        }

        User user = userRepository.findByEmail(email.trim()).orElse(null);
        if (user == null) {
            return ResponseEntity.badRequest().body(new ErrorResponse("User not found"));
        }

        user.setEmailVerified(true);
        user.setUpdatedAt(new Date());
        userRepository.save(user);

        UserResponse response = userService.mapUserToResponse(user);
        return ResponseEntity.ok(response);
    }
}
