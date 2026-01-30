package com.backend.aura.modules.activity.walking.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "walking_sessions")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WalkingSession {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(nullable = false)
    private String userId;

    @Column(nullable = false)
    private LocalDateTime startTime;

    private LocalDateTime endTime;

    @Builder.Default
    private double distanceMeters = 0.0;

    @Builder.Default
    private int durationSeconds = 0;

    @Column(columnDefinition = "TEXT")
    private String routePointsJson;

    @Builder.Default
    private boolean isActive = true;

    @Builder.Default
    private int stepsCount = 0;

    private double caloriesBurned;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        if (startTime == null) {
            startTime = LocalDateTime.now();
        }
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
