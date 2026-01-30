package com.backend.aura.modules.wellness.service;

import com.backend.aura.modules.translation.service.TranslationService;
import com.backend.aura.modules.wellness.dto.CommentDTO;
import com.backend.aura.modules.wellness.dto.CreateCommentRequest;
import com.backend.aura.modules.wellness.model.WellnessComment;
import com.backend.aura.modules.wellness.repository.WellnessCommentRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class WellnessCommentService {
    private final WellnessCommentRepository commentRepository;
    private final TranslationService translationService;

    public CommentDTO createComment(String userId, String postId, CreateCommentRequest request) {
        log.info("Creating comment for post: {} by user: {}", postId, userId);

        WellnessComment comment = WellnessComment.builder()
                .postId(postId)
                .userId(userId)
                .originalContent(request.getContent())
                .translationStatus(WellnessComment.TranslationStatus.PENDING)
                .build();

        translationService.translateToEnglish(request.getContent())
                .ifPresent(result -> {
                    comment.setDetectedLanguage(result.getDetectedLanguage());
                    if (result.isEnglish()) {
                        comment.setTranslationStatus(WellnessComment.TranslationStatus.NOT_NEEDED);
                    }
                });

        WellnessComment saved = commentRepository.save(comment);
        log.info("Comment created: {}", saved.getId());
        return CommentDTO.from(saved);
    }

    public List<CommentDTO> getComments(String postId) {
        return commentRepository.findByPostIdAndIsHiddenFalseOrderByCreatedAtDesc(postId)
                .stream()
                .map(CommentDTO::from)
                .collect(Collectors.toList());
    }

    public Page<CommentDTO> getCommentsPaged(String postId, Pageable pageable) {
        return commentRepository.findByPostIdAndIsHiddenFalseOrderByCreatedAtDesc(postId, pageable)
                .map(CommentDTO::from);
    }

    @Transactional
    public CommentDTO translateComment(String commentId) {
        WellnessComment comment = commentRepository.findById(commentId)
                .orElseThrow(() -> new RuntimeException("Comment not found"));

        if (comment.getTranslationStatus() == WellnessComment.TranslationStatus.TRANSLATED) {
            return CommentDTO.from(comment);
        }

        if (comment.getTranslationStatus() == WellnessComment.TranslationStatus.NOT_NEEDED) {
            return CommentDTO.from(comment);
        }

        log.info("Translating comment: {}", commentId);

        translationService.translateToEnglish(comment.getOriginalContent())
                .ifPresentOrElse(
                        result -> {
                            comment.setTranslatedContent(result.getTranslatedText());
                            comment.setDetectedLanguage(result.getDetectedLanguage());
                            comment.setTranslationStatus(WellnessComment.TranslationStatus.TRANSLATED);
                            log.info("Comment translated successfully: {}", commentId);
                        },
                        () -> {
                            comment.setTranslationStatus(WellnessComment.TranslationStatus.FAILED);
                            log.error("Translation failed for comment: {}", commentId);
                        });

        return CommentDTO.from(commentRepository.save(comment));
    }

    @Transactional
    public void hideComment(String commentId, String adminId) {
        WellnessComment comment = commentRepository.findById(commentId)
                .orElseThrow(() -> new RuntimeException("Comment not found"));

        comment.setHidden(true);
        comment.setModeratedBy(adminId);
        comment.setModeratedAt(LocalDateTime.now());
        commentRepository.save(comment);
        log.info("Comment hidden by admin: {} comment: {}", adminId, commentId);
    }

    @Transactional
    public void approveComment(String commentId, String adminId) {
        WellnessComment comment = commentRepository.findById(commentId)
                .orElseThrow(() -> new RuntimeException("Comment not found"));

        comment.setApproved(true);
        comment.setModeratedBy(adminId);
        comment.setModeratedAt(LocalDateTime.now());
        commentRepository.save(comment);
        log.info("Comment approved by admin: {} comment: {}", adminId, commentId);
    }

    public Page<CommentDTO> getPendingModeration(Pageable pageable) {
        return commentRepository.findByIsApprovedFalseOrderByCreatedAtDesc(pageable)
                .map(CommentDTO::from);
    }

    public long getCommentCount(String postId) {
        return commentRepository.countByPostIdAndIsHiddenFalse(postId);
    }
}
