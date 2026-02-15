package com.backend.aura.modules.messaging.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "conversations")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Conversation {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(nullable = false)
    private String participantOneId;

    @Column(nullable = false)
    private String participantTwoId;

    private LocalDateTime createdAt;

    private LocalDateTime lastMessageAt;

    private String lastMessagePreview;

    private int unreadCountOne;

    private int unreadCountTwo;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        lastMessageAt = createdAt;
    }
}
