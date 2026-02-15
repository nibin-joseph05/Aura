package com.backend.aura.modules.messaging.service;

import com.backend.aura.core.logging.AuraLogger;
import com.backend.aura.modules.messaging.model.Conversation;
import com.backend.aura.modules.messaging.model.FollowRelationship;
import com.backend.aura.modules.messaging.model.Message;
import com.backend.aura.modules.messaging.repository.ConversationRepository;
import com.backend.aura.modules.messaging.repository.FollowRelationshipRepository;
import com.backend.aura.modules.messaging.repository.MessageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class MessagingService {

    private final ConversationRepository conversationRepo;
    private final MessageRepository messageRepo;
    private final FollowRelationshipRepository followRepo;
    private final SimpMessagingTemplate messagingTemplate;
    private final AuraLogger logger;

    @Transactional
    public FollowRelationship sendFollowRequest(String fromUserId, String toUserId) {
        Optional<FollowRelationship> existing = followRepo.findByFollowerIdAndFollowingId(fromUserId, toUserId);
        if (existing.isPresent()) {
            return existing.get();
        }

        FollowRelationship follow = FollowRelationship.builder()
                .followerId(fromUserId)
                .followingId(toUserId)
                .status(FollowRelationship.FollowStatus.PENDING)
                .build();
        follow = followRepo.save(follow);
        logger.followRequestSent(fromUserId, toUserId);

        messagingTemplate.convertAndSendToUser(
                toUserId, "/queue/follow-requests",
                Map.of("type", "FOLLOW_REQUEST", "fromUserId", fromUserId, "requestId", follow.getId()));

        return follow;
    }

    @Transactional
    public FollowRelationship acceptFollowRequest(String requestId) {
        FollowRelationship follow = followRepo.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Follow request not found"));

        follow.setStatus(FollowRelationship.FollowStatus.ACCEPTED);
        follow.setAcceptedAt(LocalDateTime.now());
        follow = followRepo.save(follow);
        logger.followRequestAccepted(follow.getFollowerId(), follow.getFollowingId());

        messagingTemplate.convertAndSendToUser(
                follow.getFollowerId(), "/queue/notifications",
                Map.of("type", "FOLLOW_ACCEPTED", "userId", follow.getFollowingId()));

        return follow;
    }

    @Transactional
    public void rejectFollowRequest(String requestId) {
        FollowRelationship follow = followRepo.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Follow request not found"));
        follow.setStatus(FollowRelationship.FollowStatus.REJECTED);
        followRepo.save(follow);
    }

    public Page<FollowRelationship> getPendingFollowRequests(String userId, int page, int size) {
        return followRepo.findByFollowingIdAndStatus(userId, FollowRelationship.FollowStatus.PENDING,
                PageRequest.of(page, size));
    }

    public boolean areMutualFollowers(String userA, String userB) {
        return followRepo.existsByFollowerIdAndFollowingIdAndStatus(userA, userB,
                FollowRelationship.FollowStatus.ACCEPTED) &&
                followRepo.existsByFollowerIdAndFollowingIdAndStatus(userB, userA,
                        FollowRelationship.FollowStatus.ACCEPTED);
    }

    @Transactional
    public Conversation getOrCreateConversation(String userA, String userB) {
        if (!areMutualFollowers(userA, userB)) {
            throw new RuntimeException("Users must be mutual followers to message");
        }

        return conversationRepo.findByParticipants(userA, userB)
                .orElseGet(() -> {
                    Conversation conv = Conversation.builder()
                            .participantOneId(userA)
                            .participantTwoId(userB)
                            .build();
                    return conversationRepo.save(conv);
                });
    }

    @Transactional
    public Message sendMessage(String senderId, String conversationId, String content, Message.MessageType type) {
        Conversation conv = conversationRepo.findById(conversationId)
                .orElseThrow(() -> new RuntimeException("Conversation not found"));

        Message message = Message.builder()
                .conversationId(conversationId)
                .senderId(senderId)
                .content(content)
                .type(type)
                .build();
        message = messageRepo.save(message);

        conv.setLastMessageAt(message.getSentAt());
        conv.setLastMessagePreview(content.length() > 100 ? content.substring(0, 100) : content);

        String recipientId = conv.getParticipantOneId().equals(senderId)
                ? conv.getParticipantTwoId()
                : conv.getParticipantOneId();

        if (conv.getParticipantOneId().equals(recipientId)) {
            conv.setUnreadCountOne(conv.getUnreadCountOne() + 1);
        } else {
            conv.setUnreadCountTwo(conv.getUnreadCountTwo() + 1);
        }

        conversationRepo.save(conv);
        logger.messageSent(senderId, conversationId);

        messagingTemplate.convertAndSendToUser(
                recipientId, "/queue/messages",
                Map.of(
                        "type", "NEW_MESSAGE",
                        "conversationId", conversationId,
                        "messageId", message.getId(),
                        "senderId", senderId,
                        "content", content,
                        "messageType", type.name(),
                        "sentAt", message.getSentAt().toString()));

        return message;
    }

    public Page<Message> getMessages(String conversationId, int page, int size) {
        return messageRepo.findByConversationIdOrderBySentAtDesc(conversationId, PageRequest.of(page, size));
    }

    public Page<Conversation> getConversations(String userId, int page, int size) {
        return conversationRepo.findByParticipant(userId, PageRequest.of(page, size));
    }

    @Transactional
    public void markAsRead(String conversationId, String userId) {
        Conversation conv = conversationRepo.findById(conversationId)
                .orElseThrow(() -> new RuntimeException("Conversation not found"));

        if (conv.getParticipantOneId().equals(userId)) {
            conv.setUnreadCountOne(0);
        } else {
            conv.setUnreadCountTwo(0);
        }
        conversationRepo.save(conv);
    }

    public long getPendingFollowCount(String userId) {
        return followRepo.countByFollowingIdAndStatus(userId, FollowRelationship.FollowStatus.PENDING);
    }
}
