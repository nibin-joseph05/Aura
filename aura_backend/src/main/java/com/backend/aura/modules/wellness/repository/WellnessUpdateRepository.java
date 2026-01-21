package com.backend.aura.modules.wellness.repository;

import com.backend.aura.modules.wellness.model.WellnessUpdate;
import com.backend.aura.modules.wellness.model.enums.WellnessCategory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface WellnessUpdateRepository extends JpaRepository<WellnessUpdate, String> {

    Page<WellnessUpdate> findByIsApprovedTrueAndIsVisibleTrueOrderByCreatedAtDesc(Pageable pageable);

    Page<WellnessUpdate> findByIsApprovedTrueAndIsVisibleTrueAndCategoryOrderByCreatedAtDesc(
            WellnessCategory category, Pageable pageable);

    Page<WellnessUpdate> findByUserIdOrderByCreatedAtDesc(String userId, Pageable pageable);

    Page<WellnessUpdate> findByIsApprovedFalseAndIsVisibleTrueOrderByCreatedAtAsc(Pageable pageable);

    Page<WellnessUpdate> findAllByOrderByCreatedAtDesc(Pageable pageable);

    Page<WellnessUpdate> findByCategoryOrderByCreatedAtDesc(WellnessCategory category, Pageable pageable);

    long countByIsApprovedFalseAndIsVisibleTrue();

    long countByIsApprovedTrue();

    long countByUserId(String userId);

    @Query("SELECT COUNT(w) FROM WellnessUpdate w WHERE w.createdAt >= CURRENT_DATE")
    long countTodayUpdates();

    List<WellnessUpdate> findTop10ByIsApprovedTrueAndIsVisibleTrueOrderByLikesCountDesc();
}
