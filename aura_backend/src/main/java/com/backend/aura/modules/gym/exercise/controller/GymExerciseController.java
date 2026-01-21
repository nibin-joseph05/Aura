package com.backend.aura.modules.gym.exercise.controller;

import com.backend.aura.modules.gym.exercise.dto.GymExerciseRequest;
import com.backend.aura.modules.gym.exercise.dto.GymExerciseResponse;
import com.backend.aura.modules.gym.exercise.service.GymExerciseService;
import com.backend.aura.modules.common.dto.ErrorResponse;
import com.backend.aura.modules.common.exception.NotFoundException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/admin/gym-exercises")
public class GymExerciseController {

    private final GymExerciseService exerciseService;

    public GymExerciseController(GymExerciseService exerciseService) {
        this.exerciseService = exerciseService;
    }

    @GetMapping
    public ResponseEntity<List<GymExerciseResponse>> getAllExercises() {
        return ResponseEntity.ok(exerciseService.getAllExercises());
    }

    @GetMapping("/active")
    public ResponseEntity<List<GymExerciseResponse>> getActiveExercises() {
        return ResponseEntity.ok(exerciseService.getActiveExercises());
    }

    @GetMapping("/muscle/{targetMuscle}")
    public ResponseEntity<List<GymExerciseResponse>> getExercisesByMuscle(@PathVariable String targetMuscle) {
        return ResponseEntity.ok(exerciseService.getExercisesByMuscle(targetMuscle));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getExerciseById(@PathVariable UUID id) {
        try {
            return ResponseEntity.ok(exerciseService.getExerciseById(id));
        } catch (NotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        }
    }

    @PostMapping
    public ResponseEntity<?> createExercise(@RequestBody GymExerciseRequest request) {
        try {
            GymExerciseResponse response = exerciseService.createExercise(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(new ErrorResponse(e.getMessage()));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateExercise(
            @PathVariable UUID id,
            @RequestBody GymExerciseRequest request) {
        try {
            GymExerciseResponse response = exerciseService.updateExercise(id, request);
            return ResponseEntity.ok(response);
        } catch (NotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(new ErrorResponse(e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteExercise(@PathVariable UUID id) {
        try {
            exerciseService.deleteExercise(id);
            return ResponseEntity.noContent().build();
        } catch (NotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        }
    }

    @PatchMapping("/{id}/toggle-status")
    public ResponseEntity<?> toggleExerciseStatus(@PathVariable UUID id) {
        try {
            GymExerciseResponse response = exerciseService.toggleExerciseStatus(id);
            return ResponseEntity.ok(response);
        } catch (NotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        }
    }
}
