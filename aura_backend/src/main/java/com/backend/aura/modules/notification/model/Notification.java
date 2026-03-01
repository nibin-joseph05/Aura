package com.backend.aura.modules.notification.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "notifications")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Notification {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String body;

    private String deepLink;

    @Enumerated(EnumType.STRING)
    private NotificationType type;

    private String targetUserId;

    private boolean isBroadcast;

    private LocalDateTime createdAt;

    private LocalDateTime sentAt;

    @Enumerated(EnumType.STRING)
    private NotificationStatus status;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        if (status == null) {
            status = NotificationStatus.PENDING;
        }
    }

    public enum NotificationType {
        SYSTEM, SOS_ALERT, ANNOUNCEMENT, REMINDER, WELLNESS, AUTH_ALERT, ACCOUNT_ALERT
    }

    public enum NotificationStatus {
        PENDING, SENT, FAILED
    }
}
