package com.backend.aura.modules.activity.useractivity.controller;

import com.backend.aura.modules.activity.useractivity.dto.UserActivityRequest;
import com.backend.aura.modules.activity.useractivity.dto.UserActivityResponse;
import com.backend.aura.modules.activity.useractivity.service.UserActivityService;
import com.backend.aura.modules.common.dto.ErrorResponse;
import com.backend.aura.modules.common.exception.NotFoundException;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/user/activities")
public class UserActivityController {

    private final UserActivityService activityService;

    public UserActivityController(UserActivityService activityService) {
        this.activityService = activityService;
    }

    @GetMapping("/{userId}")
    public ResponseEntity<List<UserActivityResponse>> getUserActivities(@PathVariable String userId) {
        return ResponseEntity.ok(activityService.getUserActivities(userId));
    }

    @GetMapping("/{userId}/date/{date}")
    public ResponseEntity<List<UserActivityResponse>> getActivitiesForDate(
            @PathVariable String userId,
            @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        return ResponseEntity.ok(activityService.getUserActivitiesForDate(userId, date));
    }

    @GetMapping("/detail/{id}")
    public ResponseEntity<?> getActivityById(@PathVariable UUID id) {
        try {
            return ResponseEntity.ok(activityService.getActivityById(id));
        } catch (NotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        }
    }

    @PostMapping("/{userId}")
    public ResponseEntity<?> createActivity(
            @PathVariable String userId,
            @RequestBody UserActivityRequest request) {
        try {
            UserActivityResponse response = activityService.createActivity(userId, request);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (NotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(new ErrorResponse(e.getMessage()));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateActivity(
            @PathVariable UUID id,
            @RequestBody UserActivityRequest request) {
        try {
            UserActivityResponse response = activityService.updateActivity(id, request);
            return ResponseEntity.ok(response);
        } catch (NotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(new ErrorResponse(e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteActivity(@PathVariable UUID id) {
        try {
            activityService.deleteActivity(id);
            return ResponseEntity.noContent().build();
        } catch (NotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        }
    }

    @PatchMapping("/{id}/toggle-status")
    public ResponseEntity<?> toggleActivityStatus(@PathVariable UUID id) {
        try {
            UserActivityResponse response = activityService.toggleActivityStatus(id);
            return ResponseEntity.ok(response);
        } catch (NotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        }
    }
}
