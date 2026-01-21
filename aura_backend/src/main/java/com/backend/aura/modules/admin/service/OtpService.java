package com.backend.aura.modules.admin.service;

import com.backend.aura.modules.admin.model.OtpToken;
import com.backend.aura.modules.admin.repository.OtpTokenRepository;
import com.backend.aura.modules.mail.service.EmailService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class OtpService {

    private final OtpTokenRepository otpRepository;
    private final EmailService emailService;

    private static final int OTP_LENGTH = 6;
    private static final int OTP_EXPIRY_MINUTES = 10;

    @Transactional
    public void generateAndSendOtp(String email, String purpose) {
        otpRepository.deleteByEmailAndPurpose(email, purpose);

        String otp = generateOtp();

        OtpToken token = OtpToken.builder()
                .email(email)
                .token(otp)
                .purpose(purpose)
                .expiresAt(LocalDateTime.now().plusMinutes(OTP_EXPIRY_MINUTES))
                .build();

        otpRepository.save(token);

        emailService.sendOtpVerification(email, otp, formatPurpose(purpose));
    }

    @Transactional
    public boolean verifyOtp(String email, String otp, String purpose) {
        return otpRepository.findByEmailAndTokenAndPurposeAndUsedFalse(email, otp, purpose)
                .map(token -> {
                    if (token.isExpired()) {
                        return false;
                    }
                    token.setVerified(true);
                    token.setUsed(true);
                    otpRepository.save(token);
                    return true;
                })
                .orElse(false);
    }

    public boolean isOtpVerified(String email, String purpose) {
        return otpRepository.findFirstByEmailAndPurposeAndUsedFalseOrderByCreatedAtDesc(email, purpose)
                .map(OtpToken::isVerified)
                .orElse(false);
    }

    private String generateOtp() {
        SecureRandom random = new SecureRandom();
        StringBuilder otp = new StringBuilder();
        for (int i = 0; i < OTP_LENGTH; i++) {
            otp.append(random.nextInt(10));
        }
        return otp.toString();
    }

    private String formatPurpose(String purpose) {
        return switch (purpose) {
            case "EMAIL_CHANGE" -> "change your email address";
            case "PASSWORD_CHANGE" -> "change your password";
            case "ADMIN_ACTION" -> "verify your admin action";
            default -> "complete this action";
        };
    }
}
