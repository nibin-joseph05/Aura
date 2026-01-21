package com.backend.aura.modules.activity.log.repository;

import com.backend.aura.modules.activity.log.model.ActivityLog;
import com.backend.aura.modules.activity.log.model.enums.ActivityStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ActivityLogRepository extends JpaRepository<ActivityLog, UUID> {

    List<ActivityLog> findByUserActivityIdAndLogDate(UUID userActivityId, LocalDate logDate);

    @Query("SELECT al FROM ActivityLog al WHERE al.userActivity.userId = :userId AND al.logDate = :date")
    List<ActivityLog> findByUserIdAndDate(@Param("userId") String userId, @Param("date") LocalDate date);

    @Query("SELECT al FROM ActivityLog al WHERE al.userActivity.userId = :userId AND al.logDate BETWEEN :startDate AND :endDate")
    List<ActivityLog> findByUserIdAndDateRange(
            @Param("userId") String userId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate);

    Optional<ActivityLog> findByUserActivityIdAndLogDateAndStatus(UUID userActivityId, LocalDate logDate,
            ActivityStatus status);

    @Query("SELECT COUNT(al) FROM ActivityLog al WHERE al.userActivity.userId = :userId AND al.status = :status AND al.logDate = :date")
    long countByUserIdAndStatusAndDate(
            @Param("userId") String userId,
            @Param("status") ActivityStatus status,
            @Param("date") LocalDate date);

    boolean existsByUserActivityIdAndLogDate(UUID userActivityId, LocalDate logDate);
}
