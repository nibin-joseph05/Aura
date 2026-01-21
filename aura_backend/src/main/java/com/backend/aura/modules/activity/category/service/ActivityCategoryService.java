package com.backend.aura.modules.activity.category.service;

import com.backend.aura.modules.activity.category.dto.ActivityCategoryRequest;
import com.backend.aura.modules.activity.category.dto.ActivityCategoryResponse;
import com.backend.aura.modules.activity.category.model.ActivityCategory;
import com.backend.aura.modules.activity.category.repository.ActivityCategoryRepository;
import com.backend.aura.modules.common.exception.NotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class ActivityCategoryService {

    private final ActivityCategoryRepository categoryRepository;

    public ActivityCategoryService(ActivityCategoryRepository categoryRepository) {
        this.categoryRepository = categoryRepository;
    }

    public List<ActivityCategoryResponse> getAllCategories() {
        return categoryRepository.findAll()
                .stream()
                .map(ActivityCategoryResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public List<ActivityCategoryResponse> getActiveCategories() {
        return categoryRepository.findByIsActiveTrueOrderByNameAsc()
                .stream()
                .map(ActivityCategoryResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public ActivityCategoryResponse getCategoryById(UUID id) {
        ActivityCategory category = categoryRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Activity category not found"));
        return ActivityCategoryResponse.fromEntity(category);
    }

    public ActivityCategoryResponse createCategory(ActivityCategoryRequest request) {
        if (request.getName() == null || request.getName().isBlank()) {
            throw new IllegalArgumentException("Category name is required");
        }

        if (categoryRepository.existsByName(request.getName())) {
            throw new IllegalArgumentException("Category with this name already exists");
        }

        ActivityCategory category = new ActivityCategory();
        category.setName(request.getName());
        category.setDescription(request.getDescription());
        category.setIsActive(request.getIsActive() != null ? request.getIsActive() : true);

        ActivityCategory saved = categoryRepository.save(category);
        return ActivityCategoryResponse.fromEntity(saved);
    }

    public ActivityCategoryResponse updateCategory(UUID id, ActivityCategoryRequest request) {
        ActivityCategory category = categoryRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Activity category not found"));

        if (request.getName() != null && !request.getName().isBlank()) {
            if (categoryRepository.existsByNameAndIdNot(request.getName(), id)) {
                throw new IllegalArgumentException("Category with this name already exists");
            }
            category.setName(request.getName());
        }

        if (request.getDescription() != null) {
            category.setDescription(request.getDescription());
        }

        if (request.getIsActive() != null) {
            category.setIsActive(request.getIsActive());
        }

        ActivityCategory saved = categoryRepository.save(category);
        return ActivityCategoryResponse.fromEntity(saved);
    }

    public void deleteCategory(UUID id) {
        if (!categoryRepository.existsById(id)) {
            throw new NotFoundException("Activity category not found");
        }
        categoryRepository.deleteById(id);
    }

    public ActivityCategoryResponse toggleCategoryStatus(UUID id) {
        ActivityCategory category = categoryRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Activity category not found"));
        category.setIsActive(!category.getIsActive());
        ActivityCategory saved = categoryRepository.save(category);
        return ActivityCategoryResponse.fromEntity(saved);
    }
}
