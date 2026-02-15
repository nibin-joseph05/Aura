package com.backend.aura.modules.notification.controller;

import com.backend.aura.modules.common.dto.ApiResponse;
import com.backend.aura.modules.notification.dto.BroadcastNotificationRequest;
import com.backend.aura.modules.notification.dto.NotificationDTO;
import com.backend.aura.modules.notification.service.NotificationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @PostMapping("/admin/notifications/broadcast")
    public ResponseEntity<ApiResponse<NotificationDTO>> broadcastNotification(
            @Valid @RequestBody BroadcastNotificationRequest request) {
        NotificationDTO notification = notificationService.createBroadcastNotification(request);
        return ResponseEntity.ok(ApiResponse.success(notification, "Broadcast notification created"));
    }

    @GetMapping("/admin/notifications/broadcasts")
    public ResponseEntity<ApiResponse<Page<NotificationDTO>>> getBroadcastNotifications(Pageable pageable) {
        Page<NotificationDTO> notifications = notificationService.getBroadcastNotifications(pageable);
        return ResponseEntity.ok(ApiResponse.success(notifications, "Broadcast notifications retrieved"));
    }

    @GetMapping("/users/{userId}/notifications")
    public ResponseEntity<ApiResponse<Page<NotificationDTO>>> getUserNotifications(
            @PathVariable String userId, Pageable pageable) {
        Page<NotificationDTO> notifications = notificationService.getUserNotifications(userId, pageable);
        return ResponseEntity.ok(ApiResponse.success(notifications, "User notifications retrieved"));
    }
}
