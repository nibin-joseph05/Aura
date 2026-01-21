package com.backend.aura.modules.activity.category.dto;

import com.backend.aura.modules.activity.category.model.ActivityCategory;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class ActivityCategoryResponse {
    private UUID id;
    private String name;
    private String description;
    private Boolean isActive;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public static ActivityCategoryResponse fromEntity(ActivityCategory category) {
        ActivityCategoryResponse response = new ActivityCategoryResponse();
        response.setId(category.getId());
        response.setName(category.getName());
        response.setDescription(category.getDescription());
        response.setIsActive(category.getIsActive());
        response.setCreatedAt(category.getCreatedAt());
        response.setUpdatedAt(category.getUpdatedAt());
        return response;
    }
}
