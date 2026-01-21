package com.backend.aura.modules.activity.category.dto;

import lombok.Data;

@Data
public class ActivityCategoryRequest {
    private String name;
    private String description;
    private Boolean isActive;
}
