package com.backend.aura.modules.activity.useractivity.service;

import com.backend.aura.modules.activity.type.model.ActivityType;
import com.backend.aura.modules.activity.type.repository.ActivityTypeRepository;
import com.backend.aura.modules.activity.useractivity.dto.UserActivityRequest;
import com.backend.aura.modules.activity.useractivity.dto.UserActivityResponse;
import com.backend.aura.modules.activity.useractivity.model.UserActivity;
import com.backend.aura.modules.activity.useractivity.model.enums.RepeatType;
import com.backend.aura.modules.activity.useractivity.repository.UserActivityRepository;
import com.backend.aura.modules.common.exception.NotFoundException;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class UserActivityService {

    private final UserActivityRepository activityRepository;
    private final ActivityTypeRepository typeRepository;

    public UserActivityService(
            UserActivityRepository activityRepository,
            ActivityTypeRepository typeRepository) {
        this.activityRepository = activityRepository;
        this.typeRepository = typeRepository;
    }

    public List<UserActivityResponse> getUserActivities(String userId) {
        return activityRepository.findByUserIdAndIsActiveTrue(userId)
                .stream()
                .map(UserActivityResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public List<UserActivityResponse> getUserActivitiesForDate(String userId, LocalDate date) {
        return activityRepository.findByUserIdAndStartDate(userId, date)
                .stream()
                .map(UserActivityResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public UserActivityResponse getActivityById(UUID id) {
        UserActivity activity = activityRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("User activity not found"));
        return UserActivityResponse.fromEntity(activity);
    }

    public UserActivityResponse createActivity(String userId, UserActivityRequest request) {
        if (request.getActivityTypeId() == null) {
            throw new IllegalArgumentException("Activity type is required");
        }

        ActivityType activityType = typeRepository.findById(request.getActivityTypeId())
                .orElseThrow(() -> new NotFoundException("Activity type not found"));

        if (!activityType.getIsActive()) {
            throw new IllegalArgumentException("Selected activity type is not active");
        }

        UserActivity activity = new UserActivity();
        activity.setUserId(userId);
        activity.setActivityType(activityType);
        activity.setCustomTitle(request.getCustomTitle());
        activity.setScheduledTime(request.getScheduledTime());
        activity.setRepeatType(request.getRepeatType() != null ? request.getRepeatType() : RepeatType.NONE);
        activity.setRepeatDays(request.getRepeatDays());
        activity.setStartDate(request.getStartDate() != null ? request.getStartDate() : LocalDate.now());
        activity.setEndDate(request.getEndDate());
        activity.setEndDate(request.getEndDate());

        if (request.getIntervalMinutes() != null) {
            activity.setIntervalMinutes(request.getIntervalMinutes());
        } else {
            activity.setIntervalMinutes(activityType.getDefaultIntervalMinutes());
        }

        if (request.getTargetCompletions() != null) {
            activity.setTargetCompletions(request.getTargetCompletions());
        } else {
            activity.setTargetCompletions(
                    activityType.getDefaultTargetCompletions() != null ? activityType.getDefaultTargetCompletions()
                            : 1);
        }

        activity.setIsAlarmEnabled(request.getIsAlarmEnabled() != null ? request.getIsAlarmEnabled() : false);
        activity.setIsPushEnabled(request.getIsPushEnabled() != null ? request.getIsPushEnabled() : false);
        activity.setIsActive(request.getIsActive() != null ? request.getIsActive() : true);

        UserActivity saved = activityRepository.save(activity);
        return UserActivityResponse.fromEntity(saved);
    }

    public UserActivityResponse updateActivity(UUID id, UserActivityRequest request) {
        UserActivity activity = activityRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("User activity not found"));

        if (request.getActivityTypeId() != null) {
            ActivityType activityType = typeRepository.findById(request.getActivityTypeId())
                    .orElseThrow(() -> new NotFoundException("Activity type not found"));
            activity.setActivityType(activityType);
        }

        if (request.getCustomTitle() != null) {
            activity.setCustomTitle(request.getCustomTitle());
        }
        if (request.getScheduledTime() != null) {
            activity.setScheduledTime(request.getScheduledTime());
        }
        if (request.getRepeatType() != null) {
            activity.setRepeatType(request.getRepeatType());
        }
        if (request.getRepeatDays() != null) {
            activity.setRepeatDays(request.getRepeatDays());
        }
        if (request.getStartDate() != null) {
            activity.setStartDate(request.getStartDate());
        }
        if (request.getEndDate() != null) {
            activity.setEndDate(request.getEndDate());
        }
        if (request.getIntervalMinutes() != null) {
            activity.setIntervalMinutes(request.getIntervalMinutes());
        }
        if (request.getTargetCompletions() != null) {
            activity.setTargetCompletions(request.getTargetCompletions());
        }
        if (request.getIsAlarmEnabled() != null) {
            activity.setIsAlarmEnabled(request.getIsAlarmEnabled());
        }
        if (request.getIsPushEnabled() != null) {
            activity.setIsPushEnabled(request.getIsPushEnabled());
        }
        if (request.getIsActive() != null) {
            activity.setIsActive(request.getIsActive());
        }

        UserActivity saved = activityRepository.save(activity);
        return UserActivityResponse.fromEntity(saved);
    }

    public void deleteActivity(UUID id) {
        if (!activityRepository.existsById(id)) {
            throw new NotFoundException("User activity not found");
        }
        activityRepository.deleteById(id);
    }

    public UserActivityResponse toggleActivityStatus(UUID id) {
        UserActivity activity = activityRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("User activity not found"));
        activity.setIsActive(!activity.getIsActive());
        UserActivity saved = activityRepository.save(activity);
        return UserActivityResponse.fromEntity(saved);
    }
}
