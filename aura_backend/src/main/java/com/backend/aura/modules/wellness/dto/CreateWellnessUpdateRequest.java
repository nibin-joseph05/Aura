package com.backend.aura.modules.wellness.dto;

import com.backend.aura.modules.wellness.model.enums.WellnessCategory;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class CreateWellnessUpdateRequest {
    @NotBlank(message = "Content is required")
    @Size(max = 500, message = "Content must be 500 characters or less")
    private String content;

    private String imageUrl;

    @NotNull(message = "Category is required")
    private WellnessCategory category;
}
