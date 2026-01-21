package com.backend.aura.modules.wellness.model;

import com.backend.aura.modules.wellness.model.enums.WellnessCategory;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "wellness_updates")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WellnessUpdate {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(nullable = false)
    private String userId;

    @Column(nullable = false, length = 500)
    private String content;

    private String imageUrl;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private WellnessCategory category;

    @Builder.Default
    private int likesCount = 0;

    @Builder.Default
    private boolean isApproved = false;

    @Builder.Default
    private boolean isVisible = true;

    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();

    private LocalDateTime updatedAt;

    private String moderatedBy;

    private LocalDateTime moderatedAt;

    private String rejectionReason;

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
