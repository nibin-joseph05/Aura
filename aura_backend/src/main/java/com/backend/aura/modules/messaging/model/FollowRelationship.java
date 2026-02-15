package com.backend.aura.modules.messaging.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "follow_relationships")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FollowRelationship {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(nullable = false)
    private String followerId;

    @Column(nullable = false)
    private String followingId;

    @Enumerated(EnumType.STRING)
    @Builder.Default
    private FollowStatus status = FollowStatus.PENDING;

    private LocalDateTime createdAt;

    private LocalDateTime acceptedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }

    public enum FollowStatus {
        PENDING, ACCEPTED, REJECTED
    }
}
