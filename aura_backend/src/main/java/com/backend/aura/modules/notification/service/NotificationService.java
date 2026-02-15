package com.backend.aura.modules.notification.service;

import com.backend.aura.core.logging.AuraLogger;
import com.backend.aura.modules.notification.dto.BroadcastNotificationRequest;
import com.backend.aura.modules.notification.dto.NotificationDTO;
import com.backend.aura.modules.notification.model.Notification;
import com.backend.aura.modules.notification.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final AuraLogger auraLogger;

    @Transactional
    public NotificationDTO createBroadcastNotification(BroadcastNotificationRequest request) {
        Notification notification = Notification.builder()
                .title(request.getTitle())
                .body(request.getBody())
                .deepLink(request.getDeepLink())
                .type(Notification.NotificationType.ANNOUNCEMENT)
                .isBroadcast(true)
                .status(Notification.NotificationStatus.PENDING)
                .build();

        Notification saved = notificationRepository.save(notification);
        auraLogger.notificationCreated(saved.getId(), "broadcast");

        return NotificationDTO.from(saved);
    }

    @Transactional
    public NotificationDTO createUserNotification(String userId, String title, String body,
            Notification.NotificationType type, String deepLink) {
        Notification notification = Notification.builder()
                .title(title)
                .body(body)
                .deepLink(deepLink)
                .type(type)
                .targetUserId(userId)
                .isBroadcast(false)
                .status(Notification.NotificationStatus.PENDING)
                .build();

        Notification saved = notificationRepository.save(notification);
        auraLogger.notificationCreated(saved.getId(), userId);

        return NotificationDTO.from(saved);
    }

    @Transactional
    public void markAsSent(String notificationId) {
        notificationRepository.findById(notificationId).ifPresent(n -> {
            n.setStatus(Notification.NotificationStatus.SENT);
            n.setSentAt(LocalDateTime.now());
            notificationRepository.save(n);
        });
    }

    @Transactional
    public void markAsFailed(String notificationId) {
        notificationRepository.findById(notificationId).ifPresent(n -> {
            n.setStatus(Notification.NotificationStatus.FAILED);
            notificationRepository.save(n);
        });
    }

    public Page<NotificationDTO> getUserNotifications(String userId, Pageable pageable) {
        return notificationRepository.findByTargetUserIdOrderByCreatedAtDesc(userId, pageable)
                .map(NotificationDTO::from);
    }

    public Page<NotificationDTO> getBroadcastNotifications(Pageable pageable) {
        return notificationRepository.findByIsBroadcastTrueOrderByCreatedAtDesc(pageable)
                .map(NotificationDTO::from);
    }

    public List<Notification> getPendingNotifications() {
        return notificationRepository.findByStatus(Notification.NotificationStatus.PENDING);
    }
}
