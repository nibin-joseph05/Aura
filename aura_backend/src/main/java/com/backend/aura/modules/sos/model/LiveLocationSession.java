package com.backend.aura.modules.sos.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "live_location_sessions")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class LiveLocationSession {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private String userId;

    @Column(nullable = false)
    private Boolean active = true;

    @Column(nullable = false)
    private LocalDateTime startedAt;

    private LocalDateTime endedAt;

    private Integer durationMinutes;

    @ElementCollection
    @CollectionTable(name = "live_location_allowed_contacts", joinColumns = @JoinColumn(name = "session_id"))
    @Column(name = "contact_id")
    private List<String> allowedContactIds = new ArrayList<>();

    private String blockHash;

    private Long blockIndex;

    @OneToMany(mappedBy = "session", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("timestamp ASC")
    private List<LiveLocationPoint> points = new ArrayList<>();

    @PrePersist
    protected void onCreate() {
        if (startedAt == null) {
            startedAt = LocalDateTime.now();
        }
    }
}
