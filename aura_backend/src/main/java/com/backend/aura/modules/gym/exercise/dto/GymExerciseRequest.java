package com.backend.aura.modules.gym.exercise.dto;

import lombok.Data;

@Data
public class GymExerciseRequest {
    private String name;
    private String targetMuscle;
    private String machineName;
    private String imageUrl;
    private String description;
    private Boolean isActive;
}
