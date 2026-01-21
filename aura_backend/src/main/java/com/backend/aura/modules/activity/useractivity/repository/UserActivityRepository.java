package com.backend.aura.modules.activity.useractivity.repository;

import com.backend.aura.modules.activity.useractivity.model.UserActivity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Repository
public interface UserActivityRepository extends JpaRepository<UserActivity, UUID> {

    List<UserActivity> findByUserIdAndIsActiveTrue(String userId);

    List<UserActivity> findByUserIdAndIsActiveTrueAndStartDateLessThanEqualAndEndDateGreaterThanEqualOrEndDateIsNull(
            String userId, LocalDate date1, LocalDate date2);

    List<UserActivity> findByUserIdAndStartDate(String userId, LocalDate startDate);

    List<UserActivity> findByActivityTypeId(UUID activityTypeId);

    boolean existsByUserIdAndActivityTypeIdAndStartDate(String userId, UUID activityTypeId, LocalDate startDate);
}
