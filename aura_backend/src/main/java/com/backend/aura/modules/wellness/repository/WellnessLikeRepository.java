package com.backend.aura.modules.wellness.repository;

import com.backend.aura.modules.wellness.model.WellnessLike;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface WellnessLikeRepository extends JpaRepository<WellnessLike, String> {

    Optional<WellnessLike> findByUpdateIdAndUserId(String updateId, String userId);

    List<WellnessLike> findByUpdateId(String updateId);

    List<WellnessLike> findByUserId(String userId);

    boolean existsByUpdateIdAndUserId(String updateId, String userId);

    void deleteByUpdateIdAndUserId(String updateId, String userId);

    long countByUpdateId(String updateId);
}
