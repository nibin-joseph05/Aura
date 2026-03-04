package com.backend.aura.modules.activity.type.service;

import com.backend.aura.modules.activity.category.model.ActivityCategory;
import com.backend.aura.modules.activity.category.repository.ActivityCategoryRepository;
import com.backend.aura.modules.activity.type.dto.ActivityTypeRequest;
import com.backend.aura.modules.activity.type.dto.ActivityTypeResponse;
import com.backend.aura.modules.activity.type.model.ActivityType;
import com.backend.aura.modules.activity.type.model.ActivityMetric;
import com.backend.aura.modules.activity.type.repository.ActivityTypeRepository;
import com.backend.aura.modules.common.exception.NotFoundException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Slf4j
public class ActivityTypeService {

    private final ActivityTypeRepository typeRepository;
    private final ActivityCategoryRepository categoryRepository;

    public ActivityTypeService(
            ActivityTypeRepository typeRepository,
            ActivityCategoryRepository categoryRepository) {
        this.typeRepository = typeRepository;
        this.categoryRepository = categoryRepository;
    }

    public List<ActivityTypeResponse> getAllTypes() {
        return typeRepository.findAll()
                .stream()
                .map(ActivityTypeResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public List<ActivityTypeResponse> getActiveTypes() {
        return typeRepository.findByIsActiveTrueOrderByNameAsc()
                .stream()
                .map(ActivityTypeResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public List<ActivityTypeResponse> getTypesByCategory(UUID categoryId) {
        return typeRepository.findByCategoryId(categoryId)
                .stream()
                .map(ActivityTypeResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public List<ActivityTypeResponse> getGymActivityTypes() {
        return typeRepository.findByIsGymActivityTrue()
                .stream()
                .map(ActivityTypeResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public ActivityTypeResponse getTypeById(UUID id) {
        ActivityType type = typeRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Activity type not found"));
        return ActivityTypeResponse.fromEntity(type);
    }

    public ActivityTypeResponse createType(ActivityTypeRequest request) {
        if (request.getName() == null || request.getName().isBlank()) {
            throw new IllegalArgumentException("Activity type name is required");
        }

        if (request.getCategoryId() == null) {
            throw new IllegalArgumentException("Category ID is required");
        }

        ActivityCategory category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new NotFoundException("Activity category not found"));

        if (typeRepository.existsByNameAndCategoryId(request.getName(), request.getCategoryId())) {
            throw new IllegalArgumentException("Activity type with this name already exists in this category");
        }

        ActivityType type = new ActivityType();
        type.setCategory(category);
        type.setName(request.getName());

        log.info("Creating new ActivityType: {} in category {}", request.getName(), category.getName());
        type.setDescription(request.getDescription());
        type.setAllowAlarm(request.getAllowAlarm() != null ? request.getAllowAlarm() : false);
        type.setAllowNotes(request.getAllowNotes() != null ? request.getAllowNotes() : true);

        if (request.getMetrics() != null) {
            List<ActivityMetric> metricEntities = request.getMetrics().stream().map(mDto -> {
                ActivityMetric m = new ActivityMetric();
                m.setActivityType(type);
                m.setName(mDto.getName());
                m.setUnit(mDto.getUnit());
                m.setMetricType(mDto.getMetricType());
                m.setIsRequired(mDto.getIsRequired() != null ? mDto.getIsRequired() : false);
                return m;
            }).collect(Collectors.toList());
            type.setMetrics(metricEntities);
        }

        type.setIsGymActivity(request.getIsGymActivity() != null ? request.getIsGymActivity() : false);
        type.setIcon(request.getIcon());
        type.setColor(request.getColor());
        type.setDefaultIntervalMinutes(request.getDefaultIntervalMinutes());
        type.setDefaultTargetCompletions(
                request.getDefaultTargetCompletions() != null ? request.getDefaultTargetCompletions() : 1);
        type.setIsActive(request.getIsActive() != null ? request.getIsActive() : true);

        ActivityType saved = typeRepository.save(type);
        log.info("Successfully created ActivityType: {} with {} metrics", saved.getName(),
                saved.getMetrics() != null ? saved.getMetrics().size() : 0);
        return ActivityTypeResponse.fromEntity(saved);
    }

    public ActivityTypeResponse updateType(UUID id, ActivityTypeRequest request) {
        ActivityType type = typeRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Activity type not found"));

        if (request.getCategoryId() != null) {
            ActivityCategory category = categoryRepository.findById(request.getCategoryId())
                    .orElseThrow(() -> new NotFoundException("Activity category not found"));
            type.setCategory(category);
        }

        if (request.getName() != null && !request.getName().isBlank()) {
            UUID categoryId = request.getCategoryId() != null ? request.getCategoryId() : type.getCategory().getId();
            if (typeRepository.existsByNameAndCategoryIdAndIdNot(request.getName(), categoryId, id)) {
                throw new IllegalArgumentException("Activity type with this name already exists in this category");
            }
            type.setName(request.getName());
        }

        if (request.getDescription() != null) {
            type.setDescription(request.getDescription());
        }
        if (request.getAllowAlarm() != null) {
            type.setAllowAlarm(request.getAllowAlarm());
        }
        if (request.getAllowNotes() != null) {
            type.setAllowNotes(request.getAllowNotes());
        }

        if (request.getMetrics() != null) {
            type.getMetrics().clear();
            List<ActivityMetric> metricEntities = request.getMetrics().stream().map(mDto -> {
                ActivityMetric m = new ActivityMetric();
                m.setActivityType(type);
                m.setName(mDto.getName());
                m.setUnit(mDto.getUnit());
                m.setMetricType(mDto.getMetricType());
                m.setIsRequired(mDto.getIsRequired() != null ? mDto.getIsRequired() : false);
                return m;
            }).collect(Collectors.toList());
            type.getMetrics().addAll(metricEntities);
        }

        if (request.getIsGymActivity() != null) {
            type.setIsGymActivity(request.getIsGymActivity());
        }
        if (request.getIcon() != null) {
            type.setIcon(request.getIcon());
        }
        if (request.getColor() != null) {
            type.setColor(request.getColor());
        }
        if (request.getDefaultIntervalMinutes() != null) {
            type.setDefaultIntervalMinutes(request.getDefaultIntervalMinutes());
        }
        if (request.getDefaultTargetCompletions() != null) {
            type.setDefaultTargetCompletions(request.getDefaultTargetCompletions());
        }
        if (request.getIsActive() != null) {
            type.setIsActive(request.getIsActive());
        }

        ActivityType saved = typeRepository.save(type);
        log.info("Successfully updated ActivityType: {} with ID: {}", saved.getName(), saved.getId());
        return ActivityTypeResponse.fromEntity(saved);
    }

    public void deleteType(UUID id) {
        if (!typeRepository.existsById(id)) {
            throw new NotFoundException("Activity type not found");
        }
        typeRepository.deleteById(id);
    }

    public ActivityTypeResponse toggleTypeStatus(UUID id) {
        ActivityType type = typeRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Activity type not found"));
        type.setIsActive(!type.getIsActive());
        ActivityType saved = typeRepository.save(type);
        return ActivityTypeResponse.fromEntity(saved);
    }
}
