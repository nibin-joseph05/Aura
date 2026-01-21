package com.backend.aura.modules.sos.repository;

import com.backend.aura.modules.sos.model.SOSEvent;
import com.backend.aura.modules.sos.model.enums.SOSEventStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Repository
public interface SOSEventRepository extends JpaRepository<SOSEvent, UUID> {

    Page<SOSEvent> findAllByOrderByTriggeredAtDesc(Pageable pageable);

    Page<SOSEvent> findByStatusOrderByTriggeredAtDesc(SOSEventStatus status, Pageable pageable);

    List<SOSEvent> findByUserIdOrderByTriggeredAtDesc(String userId);

    List<SOSEvent> findByStatusIn(List<SOSEventStatus> statuses);

    @Query("SELECT COUNT(e) FROM SOSEvent e WHERE e.status = :status")
    long countByStatus(@Param("status") SOSEventStatus status);

    @Query("SELECT COUNT(e) FROM SOSEvent e WHERE e.triggeredAt >= :since")
    long countEventsSince(@Param("since") LocalDateTime since);

    @Query("SELECT COUNT(e) FROM SOSEvent e WHERE e.triggeredAt >= :since AND e.status = :status")
    long countEventsSinceWithStatus(@Param("since") LocalDateTime since, @Param("status") SOSEventStatus status);

    List<SOSEvent> findByStatusAndTriggeredAtBefore(SOSEventStatus status, LocalDateTime before);
}
