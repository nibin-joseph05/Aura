package com.backend.aura.modules.reminder.repository;

import com.backend.aura.modules.reminder.model.Reminder;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ReminderRepository extends JpaRepository<Reminder, UUID> {

    List<Reminder> findByUserActivityId(UUID userActivityId);

    @Query("SELECT r FROM Reminder r WHERE r.userActivity.userId = :userId AND r.isEnabled = true")
    List<Reminder> findEnabledRemindersByUserId(@Param("userId") String userId);

    @Query("SELECT r FROM Reminder r WHERE r.userActivity.userId = :userId")
    List<Reminder> findByUserId(@Param("userId") String userId);

    void deleteByUserActivityId(UUID userActivityId);
}
