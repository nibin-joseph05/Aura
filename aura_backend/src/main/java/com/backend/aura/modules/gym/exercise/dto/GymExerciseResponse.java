package com.backend.aura.modules.gym.exercise.dto;

import com.backend.aura.modules.gym.exercise.model.GymExercise;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class GymExerciseResponse {
    private UUID id;
    private String name;
    private String targetMuscle;
    private String machineName;
    private String imageUrl;
    private String description;
    private Boolean isActive;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public static GymExerciseResponse fromEntity(GymExercise exercise) {
        GymExerciseResponse response = new GymExerciseResponse();
        response.setId(exercise.getId());
        response.setName(exercise.getName());
        response.setTargetMuscle(exercise.getTargetMuscle());
        response.setMachineName(exercise.getMachineName());
        response.setImageUrl(exercise.getImageUrl());
        response.setDescription(exercise.getDescription());
        response.setIsActive(exercise.getIsActive());
        response.setCreatedAt(exercise.getCreatedAt());
        response.setUpdatedAt(exercise.getUpdatedAt());
        return response;
    }
}
