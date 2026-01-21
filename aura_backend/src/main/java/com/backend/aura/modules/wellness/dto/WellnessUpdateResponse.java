package com.backend.aura.modules.wellness.dto;

import com.backend.aura.modules.wellness.model.WellnessUpdate;
import com.backend.aura.modules.wellness.model.enums.WellnessCategory;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class WellnessUpdateResponse {
    private String id;
    private String userId;
    private String userName;
    private String userProfileImage;
    private String content;
    private String imageUrl;
    private WellnessCategory category;
    private int likesCount;
    private boolean likedByCurrentUser;
    private boolean isApproved;
    private LocalDateTime createdAt;

    public static WellnessUpdateResponse from(WellnessUpdate update) {
        return WellnessUpdateResponse.builder()
                .id(update.getId())
                .userId(update.getUserId())
                .content(update.getContent())
                .imageUrl(update.getImageUrl())
                .category(update.getCategory())
                .likesCount(update.getLikesCount())
                .likedByCurrentUser(false)
                .isApproved(update.isApproved())
                .createdAt(update.getCreatedAt())
                .build();
    }

    public static WellnessUpdateResponse from(WellnessUpdate update, boolean likedByCurrentUser) {
        WellnessUpdateResponse response = from(update);
        response.setLikedByCurrentUser(likedByCurrentUser);
        return response;
    }
}
