package com.backend.aura.modules.admin.repository;

import com.backend.aura.modules.admin.model.OtpToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface OtpTokenRepository extends JpaRepository<OtpToken, UUID> {

    Optional<OtpToken> findByEmailAndTokenAndPurposeAndUsedFalse(String email, String token, String purpose);

    Optional<OtpToken> findFirstByEmailAndPurposeAndUsedFalseOrderByCreatedAtDesc(String email, String purpose);

    void deleteByEmailAndPurpose(String email, String purpose);

    void deleteByExpiresAtBefore(LocalDateTime dateTime);
}
