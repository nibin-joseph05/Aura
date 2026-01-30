package com.backend.aura.modules.wellness.repository;

import com.backend.aura.modules.wellness.model.WellnessComment;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface WellnessCommentRepository extends JpaRepository<WellnessComment, String> {
    Page<WellnessComment> findByPostIdAndIsHiddenFalseOrderByCreatedAtDesc(String postId, Pageable pageable);

    List<WellnessComment> findByPostIdAndIsHiddenFalseOrderByCreatedAtDesc(String postId);

    Page<WellnessComment> findByIsApprovedFalseOrderByCreatedAtDesc(Pageable pageable);

    long countByPostIdAndIsHiddenFalse(String postId);

    long countByUserId(String userId);
}
