package com.backend.aura.modules.activity.walking.repository;

import com.backend.aura.modules.activity.walking.model.WalkingSession;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface WalkingSessionRepository extends JpaRepository<WalkingSession, String> {

    Optional<WalkingSession> findByUserIdAndIsActiveTrue(String userId);

    Page<WalkingSession> findByUserIdOrderByCreatedAtDesc(String userId, Pageable pageable);

    List<WalkingSession> findByUserIdAndIsActiveFalseOrderByCreatedAtDesc(String userId);

    List<WalkingSession> findByUserIdAndStartTimeAfterAndIsActiveFalse(String userId, LocalDateTime after);

    long countByUserIdAndIsActiveFalse(String userId);

    @Query("""
        SELECT COALESCE(SUM(w.distanceMeters), 0)
        FROM WalkingSession w
        WHERE w.userId = :userId
    """)
    double sumDistanceMetersByUserId(@Param("userId") String userId);
}
