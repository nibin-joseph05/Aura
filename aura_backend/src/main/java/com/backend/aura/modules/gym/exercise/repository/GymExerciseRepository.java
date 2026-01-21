package com.backend.aura.modules.gym.exercise.repository;

import com.backend.aura.modules.gym.exercise.model.GymExercise;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface GymExerciseRepository extends JpaRepository<GymExercise, UUID> {

    List<GymExercise> findByIsActiveTrueOrderByNameAsc();

    List<GymExercise> findByTargetMuscleIgnoreCaseAndIsActiveTrue(String targetMuscle);

    boolean existsByNameIgnoreCase(String name);

    boolean existsByNameIgnoreCaseAndIdNot(String name, UUID id);
}
