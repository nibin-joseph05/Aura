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
    private String userName;
    private String userProfileImage;
    private String content;
    private String translatedContent;
    private String detectedLanguage;
    private String translationStatus;
    private String createdAt;

    public static CommentDTO from(WellnessComment comment) {
        return CommentDTO.builder()
                .id(comment.getId())
                .postId(comment.getPostId())
                .userId(comment.getUserId())
                .content(comment.getOriginalContent())
                .translatedContent(comment.getTranslatedContent())
                .detectedLanguage(comment.getDetectedLanguage())
                .translationStatus(comment.getTranslationStatus() != null ? comment.getTranslationStatus().name() : null)
                .createdAt(comment.getCreatedAt().toString())
                .build();
    }

    public static CommentDTO from(WellnessComment comment, String userName, String userProfileImage) {
        CommentDTO dto = from(comment);
        dto.setUserName(userName);
        dto.setUserProfileImage(userProfileImage);
        return dto;
    }
}
