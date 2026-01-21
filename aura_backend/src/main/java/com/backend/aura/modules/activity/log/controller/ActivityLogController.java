package com.backend.aura.modules.activity.log.controller;

import com.backend.aura.modules.activity.log.dto.ActivityLogRequest;
import com.backend.aura.modules.activity.log.dto.ActivityLogResponse;
import com.backend.aura.modules.activity.log.service.ActivityLogService;
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
@RequestMapping("/api/user/activity-logs")
public class ActivityLogController {

    private final ActivityLogService logService;

    public ActivityLogController(ActivityLogService logService) {
        this.logService = logService;
    }

    @GetMapping("/{userId}/date/{date}")
    public ResponseEntity<List<ActivityLogResponse>> getLogsForDate(
            @PathVariable String userId,
            @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        return ResponseEntity.ok(logService.getLogsForDate(userId, date));
    }

    @GetMapping("/{userId}/range")
    public ResponseEntity<List<ActivityLogResponse>> getLogsForDateRange(
            @PathVariable String userId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return ResponseEntity.ok(logService.getLogsForDateRange(userId, startDate, endDate));
    }

    @GetMapping("/detail/{id}")
    public ResponseEntity<?> getLogById(@PathVariable UUID id) {
        try {
            return ResponseEntity.ok(logService.getLogById(id));
        } catch (NotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        }
    }

    @PostMapping
    public ResponseEntity<?> createLog(@RequestBody ActivityLogRequest request) {
        try {
            ActivityLogResponse response = logService.createLog(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (NotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(new ErrorResponse(e.getMessage()));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateLog(
            @PathVariable UUID id,
            @RequestBody ActivityLogRequest request) {
        try {
            ActivityLogResponse response = logService.updateLog(id, request);
            return ResponseEntity.ok(response);
        } catch (NotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        }
    }

    @PatchMapping("/{id}/complete")
    public ResponseEntity<?> markAsCompleted(@PathVariable UUID id) {
        try {
            ActivityLogResponse response = logService.markAsCompleted(id);
            return ResponseEntity.ok(response);
        } catch (NotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        }
    }

    @PatchMapping("/{id}/skip")
    public ResponseEntity<?> markAsSkipped(@PathVariable UUID id) {
        try {
            ActivityLogResponse response = logService.markAsSkipped(id);
            return ResponseEntity.ok(response);
        } catch (NotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteLog(@PathVariable UUID id) {
        try {
            logService.deleteLog(id);
            return ResponseEntity.noContent().build();
        } catch (NotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        }
    }
}
