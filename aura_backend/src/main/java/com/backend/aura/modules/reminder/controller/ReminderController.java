package com.backend.aura.modules.reminder.controller;

import com.backend.aura.modules.common.dto.ErrorResponse;
import com.backend.aura.modules.common.exception.NotFoundException;
import com.backend.aura.modules.reminder.dto.ReminderRequest;
import com.backend.aura.modules.reminder.dto.ReminderResponse;
import com.backend.aura.modules.reminder.service.ReminderService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/user/reminders")
public class ReminderController {

    private final ReminderService reminderService;

    public ReminderController(ReminderService reminderService) {
        this.reminderService = reminderService;
    }

    @GetMapping("/{userId}")
    public ResponseEntity<List<ReminderResponse>> getUserReminders(@PathVariable String userId) {
        return ResponseEntity.ok(reminderService.getUserReminders(userId));
    }

    @GetMapping("/{userId}/enabled")
    public ResponseEntity<List<ReminderResponse>> getEnabledReminders(@PathVariable String userId) {
        return ResponseEntity.ok(reminderService.getEnabledReminders(userId));
    }

    @GetMapping("/detail/{id}")
    public ResponseEntity<?> getReminderById(@PathVariable UUID id) {
        try {
            return ResponseEntity.ok(reminderService.getReminderById(id));
        } catch (NotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        }
    }

    @PostMapping
    public ResponseEntity<?> createReminder(@RequestBody ReminderRequest request) {
        try {
            ReminderResponse response = reminderService.createReminder(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (NotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(new ErrorResponse(e.getMessage()));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateReminder(
            @PathVariable UUID id,
            @RequestBody ReminderRequest request) {
        try {
            ReminderResponse response = reminderService.updateReminder(id, request);
            return ResponseEntity.ok(response);
        } catch (NotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        }
    }

    @PatchMapping("/{id}/toggle")
    public ResponseEntity<?> toggleReminder(@PathVariable UUID id) {
        try {
            ReminderResponse response = reminderService.toggleReminder(id);
            return ResponseEntity.ok(response);
        } catch (NotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteReminder(@PathVariable UUID id) {
        try {
            reminderService.deleteReminder(id);
            return ResponseEntity.noContent().build();
        } catch (NotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        }
    }
}
