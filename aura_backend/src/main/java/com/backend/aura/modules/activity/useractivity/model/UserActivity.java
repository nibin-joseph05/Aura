package com.backend.aura.modules.activity.useractivity.model;

import com.backend.aura.modules.activity.type.model.ActivityType;
import com.backend.aura.modules.activity.useractivity.model.enums.RepeatType;
import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.GenericGenerator;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.UUID;

@Entity
@Table(name = "user_activities")
@Data
public class UserActivity {

    @Id
    @GeneratedValue(generator = "UUID")
    @GenericGenerator(name = "UUID", strategy = "org.hibernate.id.UUIDGenerator")
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @Column(name = "user_id", nullable = false)
    private String userId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "activity_type_id", nullable = false)
    private ActivityType activityType;

    @Column(name = "custom_title")
    private String customTitle;

    @Column(name = "scheduled_time")
    private LocalTime scheduledTime;

    @Enumerated(EnumType.STRING)
    @Column(name = "repeat_type", nullable = false)
    private RepeatType repeatType = RepeatType.NONE;

    @Column(name = "repeat_days")
    private String repeatDays;

    @Column(name = "start_date", nullable = false)
    private LocalDate startDate;

    @Column(name = "end_date")
    private LocalDate endDate;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (isActive == null)
            isActive = true;
        if (repeatType == null)
            repeatType = RepeatType.NONE;
        if (startDate == null)
            startDate = LocalDate.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
