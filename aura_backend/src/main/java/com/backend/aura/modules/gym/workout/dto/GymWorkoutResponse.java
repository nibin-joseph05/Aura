package com.backend.aura.modules.gym.workout.dto;

import com.backend.aura.modules.gym.set.model.GymSet;
import com.backend.aura.modules.gym.workout.model.UserGymWorkout;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Data
public class GymWorkoutResponse {
    private UUID id;
    private UUID activityLogId;
    private UUID exerciseId;
    private String exerciseName;
    private String targetMuscle;
    private String machineName;
    private List<GymSetResponse> sets;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    @Data
    public static class GymSetResponse {
        private UUID id;
        private Integer setNumber;
        private Integer reps;
        private BigDecimal weight;
    }

    public static GymWorkoutResponse fromEntity(UserGymWorkout workout, List<GymSet> sets) {
        GymWorkoutResponse response = new GymWorkoutResponse();
        response.setId(workout.getId());
        response.setActivityLogId(workout.getActivityLog().getId());
        response.setExerciseId(workout.getExercise().getId());
        response.setExerciseName(workout.getExercise().getName());
        response.setTargetMuscle(workout.getExercise().getTargetMuscle());
        response.setMachineName(workout.getExercise().getMachineName());
        response.setCreatedAt(workout.getCreatedAt());
        response.setUpdatedAt(workout.getUpdatedAt());

        response.setSets(sets.stream().map(set -> {
            GymSetResponse setResponse = new GymSetResponse();
            setResponse.setId(set.getId());
            setResponse.setSetNumber(set.getSetNumber());
            setResponse.setReps(set.getReps());
            setResponse.setWeight(set.getWeight());
            return setResponse;
        }).collect(Collectors.toList()));

        return response;
    }
}
