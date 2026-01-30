package com.backend.aura.modules.wellness.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "wellness_comments")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WellnessComment {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(nullable = false)
    private String postId;

    @Column(nullable = false)
    private String userId;

    @Column(nullable = false, length = 1000)
    private String originalContent;

    @Column(length = 1000)
    private String translatedContent;

    private String detectedLanguage;

    @Builder.Default
    @Enumerated(EnumType.STRING)
    private TranslationStatus translationStatus = TranslationStatus.PENDING;

    @Builder.Default
    private boolean isApproved = true;

    @Builder.Default
    private boolean isHidden = false;

    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();

    private LocalDateTime updatedAt;

    private String moderatedBy;

    private LocalDateTime moderatedAt;

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    public enum TranslationStatus {
        PENDING,
        TRANSLATED,
        FAILED,
        NOT_NEEDED
    }
}
