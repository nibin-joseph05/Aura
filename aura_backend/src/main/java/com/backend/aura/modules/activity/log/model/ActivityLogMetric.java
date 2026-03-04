package com.backend.aura.modules.activity.log.model;

import com.backend.aura.modules.activity.type.model.ActivityMetric;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.Data;
import lombok.ToString;
import org.hibernate.annotations.GenericGenerator;

import java.util.UUID;

@Entity
@Table(name = "activity_log_metrics")
@Data
public class ActivityLogMetric {

    @Id
    @GeneratedValue(generator = "UUID")
    @GenericGenerator(name = "UUID", strategy = "org.hibernate.id.UUIDGenerator")
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "activity_log_id", nullable = false)
    @JsonIgnore
    @ToString.Exclude
    private ActivityLog activityLog;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "activity_metric_id", nullable = false)
    private ActivityMetric activityMetric;

    @Column(name = "metric_value")
    private String metricValue;
}
