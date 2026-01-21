package com.backend.aura.modules.sos.model;

import com.backend.aura.modules.sos.model.enums.SOSEventStatus;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "sos_events")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class SOSEvent {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private String userId;

    private String userName;

    private String userPhone;

    @Column(nullable = false)
    private Double latitude;

    @Column(nullable = false)
    private Double longitude;

    private String address;

    @Column(length = 500)
    private String message;

    @Column(nullable = false)
    private Integer contactsNotified = 0;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SOSEventStatus status = SOSEventStatus.TRIGGERED;

    @Column(nullable = false)
    private LocalDateTime triggeredAt;

    private LocalDateTime acknowledgedAt;

    private LocalDateTime resolvedAt;

    private String resolvedBy;

    private String resolutionNotes;

    @Column(nullable = false)
    private Boolean syncedFromOffline = false;

    private String deviceInfo;

    @PrePersist
    protected void onCreate() {
        if (triggeredAt == null) {
            triggeredAt = LocalDateTime.now();
        }
    }
}
