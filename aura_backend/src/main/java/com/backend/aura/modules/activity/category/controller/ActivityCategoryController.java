package com.backend.aura.modules.activity.category.controller;

import com.backend.aura.modules.activity.category.dto.ActivityCategoryRequest;
import com.backend.aura.modules.activity.category.dto.ActivityCategoryResponse;
import com.backend.aura.modules.activity.category.service.ActivityCategoryService;
import com.backend.aura.modules.common.dto.ErrorResponse;
import com.backend.aura.modules.common.exception.NotFoundException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/admin/activity-categories")
public class ActivityCategoryController {

    private final ActivityCategoryService categoryService;

    public ActivityCategoryController(ActivityCategoryService categoryService) {
        this.categoryService = categoryService;
    }

    @GetMapping
    public ResponseEntity<List<ActivityCategoryResponse>> getAllCategories() {
        return ResponseEntity.ok(categoryService.getAllCategories());
    }

    @GetMapping("/active")
    public ResponseEntity<List<ActivityCategoryResponse>> getActiveCategories() {
        return ResponseEntity.ok(categoryService.getActiveCategories());
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getCategoryById(@PathVariable UUID id) {
        try {
            return ResponseEntity.ok(categoryService.getCategoryById(id));
        } catch (NotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        }
    }

    @PostMapping
    public ResponseEntity<?> createCategory(@RequestBody ActivityCategoryRequest request) {
        try {
            ActivityCategoryResponse response = categoryService.createCategory(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(new ErrorResponse(e.getMessage()));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateCategory(
            @PathVariable UUID id,
            @RequestBody ActivityCategoryRequest request) {
        try {
            ActivityCategoryResponse response = categoryService.updateCategory(id, request);
            return ResponseEntity.ok(response);
        } catch (NotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(new ErrorResponse(e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteCategory(@PathVariable UUID id) {
        try {
            categoryService.deleteCategory(id);
            return ResponseEntity.noContent().build();
        } catch (NotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        }
    }

    @PatchMapping("/{id}/toggle-status")
    public ResponseEntity<?> toggleCategoryStatus(@PathVariable UUID id) {
        try {
            ActivityCategoryResponse response = categoryService.toggleCategoryStatus(id);
            return ResponseEntity.ok(response);
        } catch (NotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        }
    }
}
