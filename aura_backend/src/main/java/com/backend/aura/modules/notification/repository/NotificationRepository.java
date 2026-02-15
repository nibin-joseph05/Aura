package com.backend.aura.modules.notification.repository;

import com.backend.aura.modules.notification.model.Notification;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, String> {
    Page<Notification> findByTargetUserIdOrderByCreatedAtDesc(String userId, Pageable pageable);

    Page<Notification> findByIsBroadcastTrueOrderByCreatedAtDesc(Pageable pageable);

    List<Notification> findByStatus(Notification.NotificationStatus status);

    long countByTargetUserIdAndStatus(String userId, Notification.NotificationStatus status);
}
