package com.backend.aura.modules.gym.workout.repository;

import com.backend.aura.modules.gym.workout.model.UserGymWorkout;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface UserGymWorkoutRepository extends JpaRepository<UserGymWorkout, UUID> {

    List<UserGymWorkout> findByActivityLogId(UUID activityLogId);

    List<UserGymWorkout> findByExerciseId(UUID exerciseId);

    boolean existsByActivityLogIdAndExerciseId(UUID activityLogId, UUID exerciseId);
}
