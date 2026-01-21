package com.backend.aura.modules.reminder.service;

import com.backend.aura.modules.activity.useractivity.model.UserActivity;
import com.backend.aura.modules.activity.useractivity.repository.UserActivityRepository;
import com.backend.aura.modules.common.exception.NotFoundException;
import com.backend.aura.modules.reminder.dto.ReminderRequest;
import com.backend.aura.modules.reminder.dto.ReminderResponse;
import com.backend.aura.modules.reminder.model.Reminder;
import com.backend.aura.modules.reminder.repository.ReminderRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class ReminderService {

    private final ReminderRepository reminderRepository;
    private final UserActivityRepository userActivityRepository;

    public ReminderService(
            ReminderRepository reminderRepository,
            UserActivityRepository userActivityRepository) {
        this.reminderRepository = reminderRepository;
        this.userActivityRepository = userActivityRepository;
    }

    public List<ReminderResponse> getUserReminders(String userId) {
        return reminderRepository.findByUserId(userId)
                .stream()
                .map(ReminderResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public List<ReminderResponse> getEnabledReminders(String userId) {
        return reminderRepository.findEnabledRemindersByUserId(userId)
                .stream()
                .map(ReminderResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public ReminderResponse getReminderById(UUID id) {
        Reminder reminder = reminderRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Reminder not found"));
        return ReminderResponse.fromEntity(reminder);
    }

    public ReminderResponse createReminder(ReminderRequest request) {
        if (request.getUserActivityId() == null) {
            throw new IllegalArgumentException("User activity ID is required");
        }
        if (request.getReminderTime() == null) {
            throw new IllegalArgumentException("Reminder time is required");
        }

        UserActivity userActivity = userActivityRepository.findById(request.getUserActivityId())
                .orElseThrow(() -> new NotFoundException("User activity not found"));

        if (!userActivity.getActivityType().getAllowAlarm()) {
            throw new IllegalArgumentException("This activity type does not allow alarms");
        }

        Reminder reminder = new Reminder();
        reminder.setUserActivity(userActivity);
        reminder.setReminderTime(request.getReminderTime());
        reminder.setIsEnabled(request.getIsEnabled() != null ? request.getIsEnabled() : true);

        Reminder saved = reminderRepository.save(reminder);
        return ReminderResponse.fromEntity(saved);
    }

    public ReminderResponse updateReminder(UUID id, ReminderRequest request) {
        Reminder reminder = reminderRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Reminder not found"));

        if (request.getReminderTime() != null) {
            reminder.setReminderTime(request.getReminderTime());
        }
        if (request.getIsEnabled() != null) {
            reminder.setIsEnabled(request.getIsEnabled());
        }

        Reminder saved = reminderRepository.save(reminder);
        return ReminderResponse.fromEntity(saved);
    }

    public ReminderResponse toggleReminder(UUID id) {
        Reminder reminder = reminderRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Reminder not found"));
        reminder.setIsEnabled(!reminder.getIsEnabled());
        Reminder saved = reminderRepository.save(reminder);
        return ReminderResponse.fromEntity(saved);
    }

    public void deleteReminder(UUID id) {
        if (!reminderRepository.existsById(id)) {
            throw new NotFoundException("Reminder not found");
        }
        reminderRepository.deleteById(id);
    }
}
