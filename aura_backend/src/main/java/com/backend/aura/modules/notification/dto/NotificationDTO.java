package com.backend.aura.modules.notification.dto;

import com.backend.aura.modules.notification.model.Notification;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class NotificationDTO {
    private String id;
    private String title;
    private String body;
    private String deepLink;
    private String type;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime sentAt;

    public static NotificationDTO from(Notification notification) {
        return NotificationDTO.builder()
                .id(notification.getId())
                .title(notification.getTitle())
                .body(notification.getBody())
                .deepLink(notification.getDeepLink())
                .type(notification.getType() != null ? notification.getType().name() : null)
                .status(notification.getStatus() != null ? notification.getStatus().name() : null)
                .createdAt(notification.getCreatedAt())
                .sentAt(notification.getSentAt())
                .build();
    }
}
