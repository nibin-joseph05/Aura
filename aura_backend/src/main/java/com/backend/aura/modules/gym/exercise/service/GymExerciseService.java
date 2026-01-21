package com.backend.aura.modules.gym.exercise.service;

import com.backend.aura.modules.gym.exercise.dto.GymExerciseRequest;
import com.backend.aura.modules.gym.exercise.dto.GymExerciseResponse;
import com.backend.aura.modules.gym.exercise.model.GymExercise;
import com.backend.aura.modules.gym.exercise.repository.GymExerciseRepository;
import com.backend.aura.modules.common.exception.NotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class GymExerciseService {

    private final GymExerciseRepository exerciseRepository;

    public GymExerciseService(GymExerciseRepository exerciseRepository) {
        this.exerciseRepository = exerciseRepository;
    }

    public List<GymExerciseResponse> getAllExercises() {
        return exerciseRepository.findAll()
                .stream()
                .map(GymExerciseResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public List<GymExerciseResponse> getActiveExercises() {
        return exerciseRepository.findByIsActiveTrueOrderByNameAsc()
                .stream()
                .map(GymExerciseResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public List<GymExerciseResponse> getExercisesByMuscle(String targetMuscle) {
        return exerciseRepository.findByTargetMuscleIgnoreCaseAndIsActiveTrue(targetMuscle)
                .stream()
                .map(GymExerciseResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public GymExerciseResponse getExerciseById(UUID id) {
        GymExercise exercise = exerciseRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Gym exercise not found"));
        return GymExerciseResponse.fromEntity(exercise);
    }

    public GymExerciseResponse createExercise(GymExerciseRequest request) {
        if (request.getName() == null || request.getName().isBlank()) {
            throw new IllegalArgumentException("Exercise name is required");
        }

        if (exerciseRepository.existsByNameIgnoreCase(request.getName())) {
            throw new IllegalArgumentException("Exercise with this name already exists");
        }

        GymExercise exercise = new GymExercise();
        exercise.setName(request.getName());
        exercise.setTargetMuscle(request.getTargetMuscle());
        exercise.setMachineName(request.getMachineName());
        exercise.setImageUrl(request.getImageUrl());
        exercise.setDescription(request.getDescription());
        exercise.setIsActive(request.getIsActive() != null ? request.getIsActive() : true);

        GymExercise saved = exerciseRepository.save(exercise);
        return GymExerciseResponse.fromEntity(saved);
    }

    public GymExerciseResponse updateExercise(UUID id, GymExerciseRequest request) {
        GymExercise exercise = exerciseRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Gym exercise not found"));

        if (request.getName() != null && !request.getName().isBlank()) {
            if (exerciseRepository.existsByNameIgnoreCaseAndIdNot(request.getName(), id)) {
                throw new IllegalArgumentException("Exercise with this name already exists");
            }
            exercise.setName(request.getName());
        }

        if (request.getTargetMuscle() != null) {
            exercise.setTargetMuscle(request.getTargetMuscle());
        }
        if (request.getMachineName() != null) {
            exercise.setMachineName(request.getMachineName());
        }
        if (request.getImageUrl() != null) {
            exercise.setImageUrl(request.getImageUrl());
        }
        if (request.getDescription() != null) {
            exercise.setDescription(request.getDescription());
        }
        if (request.getIsActive() != null) {
            exercise.setIsActive(request.getIsActive());
        }

        GymExercise saved = exerciseRepository.save(exercise);
        return GymExerciseResponse.fromEntity(saved);
    }

    public void deleteExercise(UUID id) {
        if (!exerciseRepository.existsById(id)) {
            throw new NotFoundException("Gym exercise not found");
        }
        exerciseRepository.deleteById(id);
    }

    public GymExerciseResponse toggleExerciseStatus(UUID id) {
        GymExercise exercise = exerciseRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Gym exercise not found"));
        exercise.setIsActive(!exercise.getIsActive());
        GymExercise saved = exerciseRepository.save(exercise);
        return GymExerciseResponse.fromEntity(saved);
    }
}
