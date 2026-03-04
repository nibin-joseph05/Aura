package com.backend.aura.modules.activity.type.model;

import com.backend.aura.modules.activity.type.model.enums.MetricType;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.Data;
import lombok.ToString;
import org.hibernate.annotations.GenericGenerator;

import java.util.UUID;

@Entity
@Table(name = "activity_metrics")
@Data
public class ActivityMetric {

    @Id
    @GeneratedValue(generator = "UUID")
    @GenericGenerator(name = "UUID", strategy = "org.hibernate.id.UUIDGenerator")
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "activity_type_id", nullable = false)
    @JsonIgnore
    @ToString.Exclude
    private ActivityType activityType;

    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "unit")
    private String unit;

    @Enumerated(EnumType.STRING)
    @Column(name = "metric_type", nullable = false)
    private MetricType metricType;

    @Column(name = "is_required", nullable = false)
    private Boolean isRequired = false;
}
