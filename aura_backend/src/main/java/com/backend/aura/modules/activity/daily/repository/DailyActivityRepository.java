package com.backend.aura.modules.activity.daily.repository;

import com.backend.aura.modules.activity.daily.model.DailyActivity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;

public interface DailyActivityRepository extends JpaRepository<DailyActivity, String> {

    List<DailyActivity> findByUserIdOrderByDateDesc(String userId);

    List<DailyActivity> findByUserIdAndDateBetweenOrderByDateDesc(
            String userId, LocalDateTime start, LocalDateTime end);

    List<DailyActivity> findByUserIdAndDateOrderByCreatedAtAsc(String userId, LocalDateTime date);
}
