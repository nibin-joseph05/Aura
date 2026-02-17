package com.backend.aura.modules.notification.controller;

import com.backend.aura.modules.common.dto.ApiResponse;
import com.backend.aura.modules.notification.dto.BroadcastNotificationRequest;
import com.backend.aura.modules.notification.dto.NotificationDTO;
import com.backend.aura.modules.notification.service.NotificationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class NotificationController {

        private static final Logger log = LoggerFactory.getLogger(NotificationController.class);

        private final NotificationService notificationService;

        @PostMapping("/admin/notifications/broadcast")
        public ResponseEntity<ApiResponse<NotificationDTO>> broadcastNotification(
                        @Valid @RequestBody BroadcastNotificationRequest request) {
                log.debug("NOTIF_CTRL - POST /api/admin/notifications/broadcast | title: {} | body: {}",
                                request.getTitle(), request.getBody());
                NotificationDTO notification = notificationService.createBroadcastNotification(request);
                log.debug("NOTIF_CTRL - POST /api/admin/notifications/broadcast RESPONSE: 200 OK | id: {}",
                                notification.getId());
                return ResponseEntity.ok(ApiResponse.success(notification, "Broadcast notification created"));
        }

        @GetMapping("/admin/notifications/broadcasts")
        public ResponseEntity<ApiResponse<Page<NotificationDTO>>> getBroadcastNotifications(Pageable pageable) {
                log.debug("NOTIF_CTRL - GET /api/admin/notifications/broadcasts | page: {} | size: {}",
                                pageable.getPageNumber(), pageable.getPageSize());
                Page<NotificationDTO> notifications = notificationService.getBroadcastNotifications(pageable);
                log.debug("NOTIF_CTRL - GET /api/admin/notifications/broadcasts RESPONSE: 200 OK | count: {} | totalPages: {}",
                                notifications.getNumberOfElements(), notifications.getTotalPages());
                return ResponseEntity.ok(ApiResponse.success(notifications, "Broadcast notifications retrieved"));
        }

        @GetMapping("/users/{userId}/notifications")
        public ResponseEntity<ApiResponse<Page<NotificationDTO>>> getUserNotifications(
                        @PathVariable String userId, Pageable pageable) {
                log.debug("NOTIF_CTRL - GET /api/users/{}/notifications | page: {} | size: {}",
                                userId, pageable.getPageNumber(), pageable.getPageSize());
                Page<NotificationDTO> notifications = notificationService.getUserNotifications(userId, pageable);
                log.debug("NOTIF_CTRL - GET /api/users/{}/notifications RESPONSE: 200 OK | count: {} | totalPages: {}",
                                userId, notifications.getNumberOfElements(), notifications.getTotalPages());
                return ResponseEntity.ok(ApiResponse.success(notifications, "User notifications retrieved"));
        }
}
