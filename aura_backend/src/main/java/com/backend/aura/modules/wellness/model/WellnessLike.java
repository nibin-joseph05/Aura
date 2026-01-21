package com.backend.aura.modules.wellness.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "wellness_likes", uniqueConstraints = {
        @UniqueConstraint(columnNames = { "update_id", "user_id" })
})
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WellnessLike {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(name = "update_id", nullable = false)
    private String updateId;

    @Column(name = "user_id", nullable = false)
    private String userId;

    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();
}
