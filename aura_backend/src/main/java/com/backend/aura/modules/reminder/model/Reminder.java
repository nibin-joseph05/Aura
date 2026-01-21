package com.backend.aura.modules.reminder.model;

import com.backend.aura.modules.activity.useractivity.model.UserActivity;
import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.GenericGenerator;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.UUID;

@Entity
@Table(name = "reminders")
@Data
public class Reminder {

    @Id
    @GeneratedValue(generator = "UUID")
    @GenericGenerator(name = "UUID", strategy = "org.hibernate.id.UUIDGenerator")
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_activity_id", nullable = false)
    private UserActivity userActivity;

    @Column(name = "reminder_time", nullable = false)
    private LocalTime reminderTime;

    @Column(name = "is_enabled", nullable = false)
    private Boolean isEnabled = true;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (isEnabled == null)
            isEnabled = true;
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
