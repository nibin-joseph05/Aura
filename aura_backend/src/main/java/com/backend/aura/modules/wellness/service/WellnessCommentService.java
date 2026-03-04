package com.backend.aura.modules.wellness.service;

import com.backend.aura.modules.user.model.User;
import com.backend.aura.modules.user.repository.UserRepository;
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

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class WellnessCommentService {
    private final WellnessCommentRepository commentRepository;
    private final UserRepository userRepository;
    private final WellnessService wellnessService;

    private CommentDTO toDto(WellnessComment comment) {
        User user = userRepository.findById(comment.getUserId()).orElse(null);
        String name = user != null ? user.getName() : null;
        if (name == null || name.isBlank())
            name = user != null ? user.getUsername() : null;
        String image = user != null ? user.getProfileImageUrl() : null;
        return CommentDTO.from(comment, name, image);
    }

    @Transactional
    public CommentDTO createComment(String userId, String postId, CreateCommentRequest request) {
        WellnessComment comment = WellnessComment.builder()
                .postId(postId)
                .userId(userId)
                .originalContent(request.getContent())
                .translationStatus(WellnessComment.TranslationStatus.NOT_NEEDED)
                .build();

        WellnessComment saved = commentRepository.save(comment);
        wellnessService.incrementCommentCount(postId);
        return toDto(saved);
    }

    public List<CommentDTO> getComments(String postId) {
        return commentRepository.findByPostIdAndIsHiddenFalseOrderByCreatedAtDesc(postId)
                .stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public Page<CommentDTO> getCommentsPaged(String postId, Pageable pageable) {
        return commentRepository.findByPostIdAndIsHiddenFalseOrderByCreatedAtDesc(postId, pageable)
                .map(this::toDto);
    }

    @Transactional
    public void deleteComment(String commentId, String userId) {
        WellnessComment comment = commentRepository.findById(commentId)
                .orElseThrow(() -> new RuntimeException("Comment not found"));
        if (!comment.getUserId().equals(userId)) {
            throw new RuntimeException("Cannot delete another user's comment");
        }
        String postId = comment.getPostId();
        commentRepository.delete(comment);
        wellnessService.decrementCommentCount(postId);
    }

    public long getCommentCount(String postId) {
        return commentRepository.countByPostIdAndIsHiddenFalse(postId);
    }
}
