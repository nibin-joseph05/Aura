package com.backend.aura.modules.wellness.dto;

import com.backend.aura.modules.wellness.model.WellnessComment;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CommentDTO {
    private String id;
    private String postId;
    private String userId;
    private String originalContent;
    private String translatedContent;
    private String detectedLanguage;
    private String translationStatus;
    private boolean isApproved;
    private String createdAt;

    public static CommentDTO from(WellnessComment comment) {
        return CommentDTO.builder()
                .id(comment.getId())
                .postId(comment.getPostId())
                .userId(comment.getUserId())
                .originalContent(comment.getOriginalContent())
                .translatedContent(comment.getTranslatedContent())
                .detectedLanguage(comment.getDetectedLanguage())
                .translationStatus(comment.getTranslationStatus().name())
                .isApproved(comment.isApproved())
                .createdAt(comment.getCreatedAt().toString())
                .build();
    }
}
