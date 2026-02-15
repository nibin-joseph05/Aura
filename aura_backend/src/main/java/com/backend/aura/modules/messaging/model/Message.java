package com.backend.aura.modules.messaging.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "messages")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Message {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(nullable = false)
    private String conversationId;

    @Column(nullable = false)
    private String senderId;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String content;

    @Enumerated(EnumType.STRING)
    @Builder.Default
    private MessageType type = MessageType.TEXT;

    @Enumerated(EnumType.STRING)
    @Builder.Default
    private MessageStatus status = MessageStatus.SENT;

    private LocalDateTime sentAt;

    private LocalDateTime deliveredAt;

    private LocalDateTime readAt;

    @PrePersist
    protected void onCreate() {
        sentAt = LocalDateTime.now();
    }

    public enum MessageType {
        TEXT, IMAGE, SYSTEM
    }

    public enum MessageStatus {
        SENT, DELIVERED, READ
    }
}
