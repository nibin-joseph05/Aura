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

    Page<WellnessUpdate> findByIsVisibleTrueOrderByCreatedAtDesc(Pageable pageable);

    Page<WellnessUpdate> findByIsVisibleTrueAndCategoryOrderByCreatedAtDesc(WellnessCategory category,
            Pageable pageable);

    Page<WellnessUpdate> findByUserIdOrderByCreatedAtDesc(String userId, Pageable pageable);

    Page<WellnessUpdate> findByUserIdAndIsVisibleTrueOrderByCreatedAtDesc(String userId, Pageable pageable);

    Page<WellnessUpdate> findAllByOrderByCreatedAtDesc(Pageable pageable);

    Page<WellnessUpdate> findByUserIdAndIsVisibleTrue(String userId, Pageable pageable);

    long countByUserId(String userId);

    long countByIsVisibleTrue();

    @Query("SELECT COUNT(w) FROM WellnessUpdate w WHERE w.createdAt >= CURRENT_DATE")
    long countTodayUpdates();

    List<WellnessUpdate> findTop10ByIsVisibleTrueOrderByLikesCountDesc();
}
