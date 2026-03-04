package com.backend.aura.modules.activity.log.model;

import com.backend.aura.modules.activity.log.model.enums.ActivityStatus;
import com.backend.aura.modules.activity.useractivity.model.UserActivity;
import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.GenericGenerator;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;
import java.util.List;
import java.util.ArrayList;

@Entity
@Table(name = "activity_logs")
@Data
public class ActivityLog {

    @Id
    @GeneratedValue(generator = "UUID")
    @GenericGenerator(name = "UUID", strategy = "org.hibernate.id.UUIDGenerator")
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_activity_id", nullable = false)
    private UserActivity userActivity;

    @Column(name = "log_date", nullable = false)
    private LocalDate logDate;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private ActivityStatus status = ActivityStatus.PENDING;

    @OneToMany(mappedBy = "activityLog", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ActivityLogMetric> metrics = new ArrayList<>();

    @Column(name = "note", columnDefinition = "TEXT")
    private String note;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (status == null)
            status = ActivityStatus.PENDING;
        if (logDate == null)
            logDate = LocalDate.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
