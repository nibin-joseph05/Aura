package com.backend.aura.modules.wellness.service;

import com.backend.aura.modules.notification.model.Notification;
import com.backend.aura.modules.notification.service.NotificationService;
import com.backend.aura.modules.notification.service.PushNotificationService;
import com.backend.aura.modules.user.model.User;
import com.backend.aura.modules.user.repository.UserRepository;
import com.backend.aura.modules.wellness.dto.*;
import com.backend.aura.modules.wellness.model.WellnessLike;
import com.backend.aura.modules.wellness.model.WellnessUpdate;
import com.backend.aura.modules.wellness.model.enums.WellnessCategory;
import com.backend.aura.modules.wellness.repository.WellnessLikeRepository;
import com.backend.aura.modules.wellness.repository.WellnessUpdateRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class WellnessService {
    private final WellnessUpdateRepository updateRepository;
    private final WellnessLikeRepository likeRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;
    private final PushNotificationService pushNotificationService;

    private WellnessUpdateResponse enrich(WellnessUpdate update, boolean liked) {
        User user = userRepository.findById(update.getUserId()).orElse(null);
        String name = user != null ? user.getName() : null;
        if (name == null || name.isBlank()) {
            name = user != null ? user.getUsername() : null;
        }
        String image = user != null ? user.getProfileImageUrl() : null;
        return WellnessUpdateResponse.from(update, liked, name, image);
    }

    public Page<WellnessUpdateResponse> getFeed(String currentUserId, WellnessCategory category, Pageable pageable) {
        Page<WellnessUpdate> updates;
        if (category != null) {
            updates = updateRepository.findByIsVisibleTrueAndCategoryOrderByCreatedAtDesc(category, pageable);
        } else {
            updates = updateRepository.findByIsVisibleTrueOrderByCreatedAtDesc(pageable);
        }
        return updates.map(update -> {
            boolean liked = likeRepository.existsByUpdateIdAndUserId(update.getId(), currentUserId);
            return enrich(update, liked);
        });
    }

    public Page<WellnessUpdateResponse> getMyUpdates(String userId, Pageable pageable) {
        return updateRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable)
                .map(u -> enrich(u, likeRepository.existsByUpdateIdAndUserId(u.getId(), userId)));
    }

    public Page<WellnessUpdateResponse> getUserPosts(String userId, Pageable pageable) {
        return updateRepository.findByUserIdAndIsVisibleTrueOrderByCreatedAtDesc(userId, pageable)
                .map(u -> enrich(u, false));
    }

    public WellnessUpdateResponse createUpdate(String userId, CreateWellnessUpdateRequest request) {
        WellnessUpdate update = WellnessUpdate.builder()
                .userId(userId)
                .content(request.getContent())
                .imageUrl(request.getImageUrl())
                .category(request.getCategory())
                .isApproved(true)
                .isVisible(true)
                .build();

        WellnessUpdate saved = updateRepository.save(update);

        try {
            var notif = notificationService.createUserNotification(
                    userId, "✨ Post published!", "Your wellness post is now live on the feed.",
                    com.backend.aura.modules.notification.model.Notification.NotificationType.WELLNESS,
                    "/wellness-feed");
            User poster = userRepository.findById(userId).orElse(null);
            if (poster != null && poster.getFcmToken() != null && !poster.getFcmToken().isBlank()) {
                pushNotificationService.sendToUser(poster.getFcmToken(),
                        "✨ Post published!", "Your wellness post is now live on the feed.", "/wellness-feed");
                notificationService.markAsSent(notif.getId());
            }
        } catch (Exception ignored) {
        }

        return enrich(saved, false);
    }

    @Transactional
    public WellnessUpdateResponse editUpdate(String userId, String updateId, EditWellnessUpdateRequest request) {
        WellnessUpdate update = updateRepository.findById(updateId)
                .orElseThrow(() -> new RuntimeException("Post not found"));
        if (!update.getUserId().equals(userId)) {
            throw new RuntimeException("Cannot edit another user's post");
        }
        update.setContent(request.getContent());
        if (request.getCategory() != null) {
            update.setCategory(request.getCategory());
        }
        if (request.getImageUrl() != null) {
            update.setImageUrl(request.getImageUrl());
        }
        WellnessUpdate saved = updateRepository.save(update);
        boolean liked = likeRepository.existsByUpdateIdAndUserId(saved.getId(), userId);
        return enrich(saved, liked);
    }

    public void deleteUpdate(String userId, String updateId) {
        WellnessUpdate update = updateRepository.findById(updateId)
                .orElseThrow(() -> new RuntimeException("Post not found"));
        if (!update.getUserId().equals(userId)) {
            throw new RuntimeException("Cannot delete another user's post");
        }
        updateRepository.delete(update);
    }

    @Transactional
    public WellnessUpdateResponse likeUpdate(String userId, String updateId) {
        WellnessUpdate update = updateRepository.findById(updateId)
                .orElseThrow(() -> new RuntimeException("Post not found"));

        if (likeRepository.existsByUpdateIdAndUserId(updateId, userId)) {
            throw new RuntimeException("Already liked");
        }

        WellnessLike like = WellnessLike.builder()
                .updateId(updateId)
                .userId(userId)
                .build();
        likeRepository.save(like);

        update.setLikesCount(update.getLikesCount() + 1);
        WellnessUpdate saved = updateRepository.save(update);
        return enrich(saved, true);
    }

    @Transactional
    public WellnessUpdateResponse unlikeUpdate(String userId, String updateId) {
        WellnessUpdate update = updateRepository.findById(updateId)
                .orElseThrow(() -> new RuntimeException("Post not found"));

        likeRepository.deleteByUpdateIdAndUserId(updateId, userId);

        update.setLikesCount(Math.max(0, update.getLikesCount() - 1));
        WellnessUpdate saved = updateRepository.save(update);
        return enrich(saved, false);
    }

    public void incrementCommentCount(String postId) {
        updateRepository.findById(postId).ifPresent(u -> {
            u.setCommentsCount(u.getCommentsCount() + 1);
            updateRepository.save(u);
        });
    }

    public void decrementCommentCount(String postId) {
        updateRepository.findById(postId).ifPresent(u -> {
            u.setCommentsCount(Math.max(0, u.getCommentsCount() - 1));
            updateRepository.save(u);
        });
    }

    public Page<WellnessUpdateResponse> getAllUpdates(String userId, WellnessCategory category, Pageable pageable) {
        Page<WellnessUpdate> updates;
        if (userId != null && !userId.isBlank()) {
            updates = updateRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable);
        } else if (category != null) {
            updates = updateRepository.findByIsVisibleTrueAndCategoryOrderByCreatedAtDesc(category, pageable);
        } else {
            updates = updateRepository.findAllByOrderByCreatedAtDesc(pageable);
        }
        return updates.map(u -> enrich(u, false));
    }

    public void adminDeleteUpdate(String updateId) {
        WellnessUpdate update = updateRepository.findById(updateId)
                .orElseThrow(() -> new RuntimeException("Post not found"));
        updateRepository.delete(update);
    }

    public void adminHideUpdate(String updateId) {
        WellnessUpdate update = updateRepository.findById(updateId)
                .orElseThrow(() -> new RuntimeException("Post not found"));
        update.setVisible(false);
        update.setModeratedAt(LocalDateTime.now());
        updateRepository.save(update);
    }

    public void warnUser(String postId, String adminId, String message) {
        WellnessUpdate update = updateRepository.findById(postId)
                .orElseThrow(() -> new RuntimeException("Post not found"));
        String title = "⚠️ Content Warning";
        String body = message != null && !message.isBlank() ? message
                : "One of your posts was flagged by our moderators. Please review our community guidelines.";
        var notification = notificationService.createUserNotification(
                update.getUserId(), title, body,
                Notification.NotificationType.WELLNESS, "/wellness-feed");
        try {
            User user = userRepository.findById(update.getUserId()).orElse(null);
            if (user != null && user.getFcmToken() != null && !user.getFcmToken().isBlank()) {
                pushNotificationService.sendToUser(user.getFcmToken(), title, body, "/wellness-feed");
                notificationService.markAsSent(notification.getId());
            }
        } catch (Exception ignored) {
        }
    }

    public WellnessStatsResponse getStats() {
        return WellnessStatsResponse.builder()
                .totalUpdates(updateRepository.count())
                .approvedUpdates(updateRepository.countByIsVisibleTrue())
                .pendingUpdates(0)
                .todayUpdates(updateRepository.countTodayUpdates())
                .build();
    }

    public List<WellnessUpdateResponse> getTrendingUpdates() {
        return updateRepository.findTop10ByIsVisibleTrueOrderByLikesCountDesc()
                .stream()
                .map(u -> enrich(u, false))
                .collect(Collectors.toList());
    }
}
