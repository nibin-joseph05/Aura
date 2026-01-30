package com.backend.aura.modules.wellness.service;

import com.backend.aura.modules.translation.service.TranslationService;
import com.backend.aura.modules.wellness.dto.*;
import com.backend.aura.modules.wellness.model.WellnessLike;
import com.backend.aura.modules.wellness.model.WellnessUpdate;
import com.backend.aura.modules.wellness.model.enums.WellnessCategory;
import com.backend.aura.modules.wellness.repository.WellnessLikeRepository;
import com.backend.aura.modules.wellness.repository.WellnessUpdateRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class WellnessService {
    private final WellnessUpdateRepository updateRepository;
    private final WellnessLikeRepository likeRepository;
    private final TranslationService translationService;

    public Page<WellnessUpdateResponse> getFeed(String currentUserId, WellnessCategory category, Pageable pageable) {
        Page<WellnessUpdate> updates;
        if (category != null) {
            updates = updateRepository.findByIsApprovedTrueAndIsVisibleTrueAndCategoryOrderByCreatedAtDesc(category,
                    pageable);
        } else {
            updates = updateRepository.findByIsApprovedTrueAndIsVisibleTrueOrderByCreatedAtDesc(pageable);
        }
        return updates.map(update -> {
            boolean liked = likeRepository.existsByUpdateIdAndUserId(update.getId(), currentUserId);
            return WellnessUpdateResponse.from(update, liked);
        });
    }

    public Page<WellnessUpdateResponse> getMyUpdates(String userId, Pageable pageable) {
        return updateRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable)
                .map(WellnessUpdateResponse::from);
    }

    public WellnessUpdateResponse createUpdate(String userId, CreateWellnessUpdateRequest request) {
        WellnessUpdate update = WellnessUpdate.builder()
                .userId(userId)
                .content(request.getContent())
                .imageUrl(request.getImageUrl())
                .category(request.getCategory())
                .isApproved(false)
                .isVisible(true)
                .build();

        translationService.translateToEnglish(request.getContent())
                .ifPresentOrElse(
                        result -> {
                            update.setTranslatedContent(result.getTranslatedText());
                            update.setDetectedLanguage(result.getDetectedLanguage());
                            update.setTranslationFailed(false);
                        },
                        () -> {
                            update.setTranslatedContent(request.getContent());
                            update.setTranslationFailed(true);
                        });

        WellnessUpdate saved = updateRepository.save(update);
        return WellnessUpdateResponse.from(saved);
    }

    public void deleteUpdate(String userId, String updateId) {
        WellnessUpdate update = updateRepository.findById(updateId)
                .orElseThrow(() -> new RuntimeException("Update not found"));
        if (!update.getUserId().equals(userId)) {
            throw new RuntimeException("Cannot delete another user's update");
        }
        updateRepository.delete(update);
    }

    @Transactional
    public WellnessUpdateResponse likeUpdate(String userId, String updateId) {
        WellnessUpdate update = updateRepository.findById(updateId)
                .orElseThrow(() -> new RuntimeException("Update not found"));

        if (likeRepository.existsByUpdateIdAndUserId(updateId, userId)) {
            throw new RuntimeException("Already liked");
        }

        WellnessLike like = WellnessLike.builder()
                .updateId(updateId)
                .userId(userId)
                .build();
        likeRepository.save(like);

        update.setLikesCount(update.getLikesCount() + 1);
        WellnessUpdate saved = updateRepository.save(update);
        return WellnessUpdateResponse.from(saved, true);
    }

    @Transactional
    public WellnessUpdateResponse unlikeUpdate(String userId, String updateId) {
        WellnessUpdate update = updateRepository.findById(updateId)
                .orElseThrow(() -> new RuntimeException("Update not found"));

        likeRepository.deleteByUpdateIdAndUserId(updateId, userId);

        update.setLikesCount(Math.max(0, update.getLikesCount() - 1));
        WellnessUpdate saved = updateRepository.save(update);
        return WellnessUpdateResponse.from(saved, false);
    }

    public Page<WellnessUpdateResponse> getPendingUpdates(Pageable pageable) {
        return updateRepository.findByIsApprovedFalseAndIsVisibleTrueOrderByCreatedAtAsc(pageable)
                .map(WellnessUpdateResponse::from);
    }

    public Page<WellnessUpdateResponse> getAllUpdates(WellnessCategory category, Pageable pageable) {
        if (category != null) {
            return updateRepository.findByCategoryOrderByCreatedAtDesc(category, pageable)
                    .map(WellnessUpdateResponse::from);
        }
        return updateRepository.findAllByOrderByCreatedAtDesc(pageable)
                .map(WellnessUpdateResponse::from);
    }

    public WellnessUpdateResponse approveUpdate(String updateId, String adminId) {
        WellnessUpdate update = updateRepository.findById(updateId)
                .orElseThrow(() -> new RuntimeException("Update not found"));
        update.setApproved(true);
        update.setModeratedBy(adminId);
        update.setModeratedAt(LocalDateTime.now());
        update.setRejectionReason(null);
        WellnessUpdate saved = updateRepository.save(update);
        return WellnessUpdateResponse.from(saved);
    }

    public WellnessUpdateResponse rejectUpdate(String updateId, String adminId, String reason) {
        WellnessUpdate update = updateRepository.findById(updateId)
                .orElseThrow(() -> new RuntimeException("Update not found"));
        update.setApproved(false);
        update.setVisible(false);
        update.setModeratedBy(adminId);
        update.setModeratedAt(LocalDateTime.now());
        update.setRejectionReason(reason);
        WellnessUpdate saved = updateRepository.save(update);
        return WellnessUpdateResponse.from(saved);
    }

    public void adminDeleteUpdate(String updateId) {
        WellnessUpdate update = updateRepository.findById(updateId)
                .orElseThrow(() -> new RuntimeException("Update not found"));
        updateRepository.delete(update);
    }

    public WellnessStatsResponse getStats() {
        return WellnessStatsResponse.builder()
                .totalUpdates(updateRepository.count())
                .approvedUpdates(updateRepository.countByIsApprovedTrue())
                .pendingUpdates(updateRepository.countByIsApprovedFalseAndIsVisibleTrue())
                .todayUpdates(updateRepository.countTodayUpdates())
                .build();
    }

    public List<WellnessUpdateResponse> getTrendingUpdates() {
        return updateRepository.findTop10ByIsApprovedTrueAndIsVisibleTrueOrderByLikesCountDesc()
                .stream()
                .map(WellnessUpdateResponse::from)
                .collect(Collectors.toList());
    }
}
