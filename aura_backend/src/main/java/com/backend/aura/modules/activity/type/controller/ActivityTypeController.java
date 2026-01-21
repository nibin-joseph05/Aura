package com.backend.aura.modules.activity.type.controller;

import com.backend.aura.modules.activity.type.dto.ActivityTypeRequest;
import com.backend.aura.modules.activity.type.dto.ActivityTypeResponse;
import com.backend.aura.modules.activity.type.service.ActivityTypeService;
import com.backend.aura.modules.common.dto.ErrorResponse;
import com.backend.aura.modules.common.exception.NotFoundException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/admin/activity-types")
public class ActivityTypeController {

    private final ActivityTypeService typeService;

    public ActivityTypeController(ActivityTypeService typeService) {
        this.typeService = typeService;
    }

    @GetMapping
    public ResponseEntity<List<ActivityTypeResponse>> getAllTypes() {
        return ResponseEntity.ok(typeService.getAllTypes());
    }

    @GetMapping("/active")
    public ResponseEntity<List<ActivityTypeResponse>> getActiveTypes() {
        return ResponseEntity.ok(typeService.getActiveTypes());
    }

    @GetMapping("/category/{categoryId}")
    public ResponseEntity<List<ActivityTypeResponse>> getTypesByCategory(@PathVariable UUID categoryId) {
        return ResponseEntity.ok(typeService.getTypesByCategory(categoryId));
    }

    @GetMapping("/gym")
    public ResponseEntity<List<ActivityTypeResponse>> getGymActivityTypes() {
        return ResponseEntity.ok(typeService.getGymActivityTypes());
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getTypeById(@PathVariable UUID id) {
        try {
            return ResponseEntity.ok(typeService.getTypeById(id));
        } catch (NotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        }
    }

    @PostMapping
    public ResponseEntity<?> createType(@RequestBody ActivityTypeRequest request) {
        try {
            ActivityTypeResponse response = typeService.createType(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (NotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(new ErrorResponse(e.getMessage()));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateType(
            @PathVariable UUID id,
            @RequestBody ActivityTypeRequest request) {
        try {
            ActivityTypeResponse response = typeService.updateType(id, request);
            return ResponseEntity.ok(response);
        } catch (NotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(new ErrorResponse(e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteType(@PathVariable UUID id) {
        try {
            typeService.deleteType(id);
            return ResponseEntity.noContent().build();
        } catch (NotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        }
    }

    @PatchMapping("/{id}/toggle-status")
    public ResponseEntity<?> toggleTypeStatus(@PathVariable UUID id) {
        try {
            ActivityTypeResponse response = typeService.toggleTypeStatus(id);
            return ResponseEntity.ok(response);
        } catch (NotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        }
    }
}
