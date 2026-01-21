package com.backend.aura.modules.gym.set.repository;

import com.backend.aura.modules.gym.set.model.GymSet;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface GymSetRepository extends JpaRepository<GymSet, UUID> {

    List<GymSet> findByWorkoutIdOrderBySetNumberAsc(UUID workoutId);

    void deleteByWorkoutId(UUID workoutId);
}
