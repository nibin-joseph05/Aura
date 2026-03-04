package com.backend.aura.modules.wellness.dto;

import com.backend.aura.modules.wellness.model.enums.WellnessCategory;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class EditWellnessUpdateRequest {
    @NotBlank
    @Size(min = 1, max = 1000)
    private String content;

    private WellnessCategory category;

    private String imageUrl;
}
