package com.backend.aura.modules.gym.workout.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Data
public class GymWorkoutRequest {
    private UUID activityLogId;
    private UUID exerciseId;
    private List<GymSetData> sets;

    @Data
    public static class GymSetData {
        private Integer setNumber;
        private Integer reps;
        private BigDecimal weight;
    }
}
