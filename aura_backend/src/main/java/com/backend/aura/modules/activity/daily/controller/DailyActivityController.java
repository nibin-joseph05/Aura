package com.backend.aura.modules.activity.daily.controller;

import com.backend.aura.modules.activity.daily.model.DailyActivity;
import com.backend.aura.modules.activity.daily.repository.DailyActivityRepository;
import com.backend.aura.modules.common.dto.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/daily-activities")
@RequiredArgsConstructor
public class DailyActivityController {

    private static final Logger log = LoggerFactory.getLogger(DailyActivityController.class);

    private final DailyActivityRepository dailyActivityRepository;

    @GetMapping
    public ResponseEntity<ApiResponse<Map<String, Object>>> getActivities(
            @AuthenticationPrincipal String userId,
            @RequestParam(required = false) String date) {

        log.debug("DAILY_ACT_CTRL - GET /api/daily-activities | userId: {} | date: {}", userId, date);

        List<DailyActivity> activities;
        if (date != null && !date.isEmpty()) {
            LocalDate localDate = LocalDate.parse(date.substring(0, 10));
            LocalDateTime start = localDate.atStartOfDay();
            LocalDateTime end = localDate.atTime(LocalTime.MAX);
            activities = dailyActivityRepository.findByUserIdAndDateBetweenOrderByDateDesc(userId, start, end);
        } else {
            activities = dailyActivityRepository.findByUserIdOrderByDateDesc(userId);
        }

        log.debug("DAILY_ACT_CTRL - GET /api/daily-activities RESPONSE: 200 OK | userId: {} | count: {}",
                userId, activities.size());

        return ResponseEntity.ok(ApiResponse.success(Map.of("activities", activities)));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<DailyActivity>> createActivity(
            @AuthenticationPrincipal String userId,
            @RequestBody DailyActivity activity) {

        log.debug("DAILY_ACT_CTRL - POST /api/daily-activities | userId: {} | title: {} | type: {}",
                userId, activity.getTitle(), activity.getActivityType());

        activity.setUserId(userId);
        DailyActivity saved = dailyActivityRepository.save(activity);

        log.debug("DAILY_ACT_CTRL - POST /api/daily-activities RESPONSE: 200 OK | id: {}", saved.getId());
        return ResponseEntity.ok(ApiResponse.success(saved));
    }

    @PostMapping("/sync")
    public ResponseEntity<ApiResponse<Map<String, Object>>> syncActivities(
            @AuthenticationPrincipal String userId,
            @RequestBody Map<String, List<Map<String, Object>>> body) {

        log.debug("DAILY_ACT_CTRL - POST /api/daily-activities/sync | userId: {}", userId);

        List<Map<String, Object>> activitiesData = body.get("activities");
        if (activitiesData == null) {
            activitiesData = new ArrayList<>();
        }

        int synced = 0;
        for (Map<String, Object> actData : activitiesData) {
            DailyActivity activity = new DailyActivity();
            activity.setUserId(userId);
            activity.setDate(LocalDateTime.parse((String) actData.get("date")));
            activity.setActivityType((String) actData.get("activityType"));
            activity.setTitle((String) actData.get("title"));
            activity.setDescription((String) actData.get("description"));
            if (actData.get("completedAt") != null) {
                activity.setCompletedAt(LocalDateTime.parse((String) actData.get("completedAt")));
            }
            dailyActivityRepository.save(activity);
            synced++;
        }

        log.debug("DAILY_ACT_CTRL - POST /api/daily-activities/sync RESPONSE: 200 OK | userId: {} | synced: {}",
                userId, synced);

        return ResponseEntity.ok(ApiResponse.success(Map.of("synced", synced)));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<DailyActivity>> updateActivity(
            @AuthenticationPrincipal String userId,
            @PathVariable String id,
            @RequestBody DailyActivity activity) {

        log.debug("DAILY_ACT_CTRL - PUT /api/daily-activities/{} | userId: {}", id, userId);

        DailyActivity existing = dailyActivityRepository.findById(id).orElse(null);
        if (existing == null) {
            log.debug("DAILY_ACT_CTRL - PUT /api/daily-activities/{} RESPONSE: 404 Not Found", id);
            return ResponseEntity.notFound().build();
        }

        if (!existing.getUserId().equals(userId)) {
            log.debug(
                    "DAILY_ACT_CTRL - PUT /api/daily-activities/{} RESPONSE: 403 Forbidden | owner: {} | requester: {}",
                    id, existing.getUserId(), userId);
            return ResponseEntity.status(403).build();
        }

        if (activity.getTitle() != null)
            existing.setTitle(activity.getTitle());
        if (activity.getDescription() != null)
            existing.setDescription(activity.getDescription());
        if (activity.getActivityType() != null)
            existing.setActivityType(activity.getActivityType());
        if (activity.getDate() != null)
            existing.setDate(activity.getDate());
        if (activity.getCompletedAt() != null)
            existing.setCompletedAt(activity.getCompletedAt());

        DailyActivity saved = dailyActivityRepository.save(existing);

        log.debug("DAILY_ACT_CTRL - PUT /api/daily-activities/{} RESPONSE: 200 OK", id);
        return ResponseEntity.ok(ApiResponse.success(saved));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteActivity(
            @AuthenticationPrincipal String userId,
            @PathVariable String id) {

        log.debug("DAILY_ACT_CTRL - DELETE /api/daily-activities/{} | userId: {}", id, userId);

        DailyActivity existing = dailyActivityRepository.findById(id).orElse(null);
        if (existing == null) {
            log.debug("DAILY_ACT_CTRL - DELETE /api/daily-activities/{} RESPONSE: 404 Not Found", id);
            return ResponseEntity.notFound().build();
        }

        if (!existing.getUserId().equals(userId)) {
            log.debug("DAILY_ACT_CTRL - DELETE /api/daily-activities/{} RESPONSE: 403 Forbidden", id);
            return ResponseEntity.status(403).build();
        }

        dailyActivityRepository.deleteById(id);

        log.debug("DAILY_ACT_CTRL - DELETE /api/daily-activities/{} RESPONSE: 200 OK", id);
        return ResponseEntity.ok(ApiResponse.success(null));
    }
}
