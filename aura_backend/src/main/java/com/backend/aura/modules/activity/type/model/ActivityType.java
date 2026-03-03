package com.backend.aura.modules.activity.type.model;

import com.backend.aura.modules.activity.category.model.ActivityCategory;
import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.GenericGenerator;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "activity_types")
@Data
public class ActivityType {

    @Id
    @GeneratedValue(generator = "UUID")
    @GenericGenerator(name = "UUID", strategy = "org.hibernate.id.UUIDGenerator")
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id", nullable = false)
    private ActivityCategory category;

    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "description")
    private String description;

    @Column(name = "allow_alarm", nullable = false)
    private Boolean allowAlarm = false;

    @Column(name = "allow_notes", nullable = false)
    private Boolean allowNotes = true;

    @Column(name = "requires_duration", nullable = false)
    private Boolean requiresDuration = false;

    @Column(name = "requires_distance", nullable = false)
    private Boolean requiresDistance = false;

    @Column(name = "requires_calories", nullable = false)
    private Boolean requiresCalories = false;

    @Column(name = "is_gym_activity", nullable = false)
    private Boolean isGymActivity = false;

    @Column(name = "icon")
    private String icon;

    @Column(name = "color")
    private String color;

    @Column(name = "default_interval_minutes")
    private Integer defaultIntervalMinutes;

    @Column(name = "default_target_completions", nullable = false)
    private Integer defaultTargetCompletions = 1;

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
        if (allowAlarm == null)
            allowAlarm = false;
        if (allowNotes == null)
            allowNotes = true;
        if (requiresDuration == null)
            requiresDuration = false;
        if (requiresDistance == null)
            requiresDistance = false;
        if (requiresCalories == null)
            requiresCalories = false;
        if (isGymActivity == null)
            isGymActivity = false;
        if (defaultTargetCompletions == null)
            defaultTargetCompletions = 1;
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
