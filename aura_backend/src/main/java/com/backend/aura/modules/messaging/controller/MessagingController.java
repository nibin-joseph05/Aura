package com.backend.aura.modules.messaging.controller;

import com.backend.aura.modules.messaging.model.Conversation;
import com.backend.aura.modules.messaging.model.FollowRelationship;
import com.backend.aura.modules.messaging.model.Message;
import com.backend.aura.modules.messaging.service.MessagingService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/messaging")
@RequiredArgsConstructor
public class MessagingController {

    private static final Logger log = LoggerFactory.getLogger(MessagingController.class);

    private final MessagingService messagingService;

    @PostMapping("/follow/request")
    public ResponseEntity<FollowRelationship> sendFollowRequest(@RequestBody Map<String, String> body) {
        log.debug("MSG_CTRL - POST /api/messaging/follow/request | from: {} | to: {}",
                body.get("fromUserId"), body.get("toUserId"));
        FollowRelationship result = messagingService.sendFollowRequest(body.get("fromUserId"), body.get("toUserId"));
        log.debug("MSG_CTRL - POST /api/messaging/follow/request RESPONSE: 200 OK | id: {} | status: {}",
                result.getId(), result.getStatus());
        return ResponseEntity.ok(result);
    }

    @PostMapping("/follow/accept/{requestId}")
    public ResponseEntity<FollowRelationship> acceptFollow(@PathVariable String requestId) {
        log.debug("MSG_CTRL - POST /api/messaging/follow/accept/{}", requestId);
        FollowRelationship result = messagingService.acceptFollowRequest(requestId);
        log.debug("MSG_CTRL - POST /api/messaging/follow/accept/{} RESPONSE: 200 OK | status: {}",
                requestId, result.getStatus());
        return ResponseEntity.ok(result);
    }

    @PostMapping("/follow/reject/{requestId}")
    public ResponseEntity<Void> rejectFollow(@PathVariable String requestId) {
        log.debug("MSG_CTRL - POST /api/messaging/follow/reject/{}", requestId);
        messagingService.rejectFollowRequest(requestId);
        log.debug("MSG_CTRL - POST /api/messaging/follow/reject/{} RESPONSE: 200 OK", requestId);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/follow/unfollow")
    public ResponseEntity<Void> unfollow(@RequestBody Map<String, String> body) {
        log.debug("MSG_CTRL - POST /api/messaging/follow/unfollow | from: {} | to: {}",
                body.get("fromUserId"), body.get("toUserId"));
        messagingService.unfollow(body.get("fromUserId"), body.get("toUserId"));
        log.debug("MSG_CTRL - POST /api/messaging/follow/unfollow RESPONSE: 200 OK");
        return ResponseEntity.ok().build();
    }

    @GetMapping("/follow/pending/{userId}")
    public ResponseEntity<Page<FollowRelationship>> getPendingRequests(
            @PathVariable String userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        log.debug("MSG_CTRL - GET /api/messaging/follow/pending/{} | page: {} | size: {}", userId, page, size);
        Page<FollowRelationship> result = messagingService.getPendingFollowRequests(userId, page, size);
        log.debug("MSG_CTRL - GET /api/messaging/follow/pending/{} RESPONSE: 200 OK | count: {}",
                userId, result.getNumberOfElements());
        return ResponseEntity.ok(result);
    }

    @GetMapping("/follow/count/{userId}")
    public ResponseEntity<Map<String, Long>> getPendingCount(@PathVariable String userId) {
        log.debug("MSG_CTRL - GET /api/messaging/follow/count/{}", userId);
        Long count = messagingService.getPendingFollowCount(userId);
        log.debug("MSG_CTRL - GET /api/messaging/follow/count/{} RESPONSE: 200 OK | count: {}", userId, count);
        return ResponseEntity.ok(Map.of("count", count));
    }

    @GetMapping("/follow/followers/{userId}")
    public ResponseEntity<Page<FollowRelationship>> getFollowers(
            @PathVariable String userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        log.debug("MSG_CTRL - GET /api/messaging/follow/followers/{} | page: {} | size: {}", userId, page, size);
        Page<FollowRelationship> result = messagingService.getFollowers(userId, page, size);
        log.debug("MSG_CTRL - GET /api/messaging/follow/followers/{} RESPONSE: 200 OK | count: {}",
                userId, result.getNumberOfElements());
        return ResponseEntity.ok(result);
    }

    @GetMapping("/follow/following/{userId}")
    public ResponseEntity<Page<FollowRelationship>> getFollowing(
            @PathVariable String userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        log.debug("MSG_CTRL - GET /api/messaging/follow/following/{} | page: {} | size: {}", userId, page, size);
        Page<FollowRelationship> result = messagingService.getFollowing(userId, page, size);
        log.debug("MSG_CTRL - GET /api/messaging/follow/following/{} RESPONSE: 200 OK | count: {}",
                userId, result.getNumberOfElements());
        return ResponseEntity.ok(result);
    }

    @GetMapping("/follow/status")
    public ResponseEntity<Map<String, Object>> getFollowStatus(
            @RequestParam String fromUserId,
            @RequestParam String toUserId) {
        log.debug("MSG_CTRL - GET /api/messaging/follow/status | from: {} | to: {}", fromUserId, toUserId);
        Map<String, Object> result = messagingService.getFollowStatus(fromUserId, toUserId);
        log.debug("MSG_CTRL - GET /api/messaging/follow/status RESPONSE: 200 OK | status: {}", result);
        return ResponseEntity.ok(result);
    }

    @PostMapping("/conversations")
    public ResponseEntity<Conversation> getOrCreateConversation(@RequestBody Map<String, String> body) {
        log.debug("MSG_CTRL - POST /api/messaging/conversations | userA: {} | userB: {}",
                body.get("userA"), body.get("userB"));
        Conversation result = messagingService.getOrCreateConversation(body.get("userA"), body.get("userB"));
        log.debug("MSG_CTRL - POST /api/messaging/conversations RESPONSE: 200 OK | id: {}", result.getId());
        return ResponseEntity.ok(result);
    }

    @GetMapping("/conversations/{userId}")
    public ResponseEntity<Page<Conversation>> getConversations(
            @PathVariable String userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        log.debug("MSG_CTRL - GET /api/messaging/conversations/{} | page: {} | size: {}", userId, page, size);
        Page<Conversation> result = messagingService.getConversations(userId, page, size);
        log.debug("MSG_CTRL - GET /api/messaging/conversations/{} RESPONSE: 200 OK | count: {}",
                userId, result.getNumberOfElements());
        return ResponseEntity.ok(result);
    }

    @PostMapping("/messages")
    public ResponseEntity<Message> sendMessage(@RequestBody Map<String, String> body) {
        Message.MessageType type = Message.MessageType.valueOf(
                body.getOrDefault("type", "TEXT"));
        log.debug("MSG_CTRL - POST /api/messaging/messages | sender: {} | conversation: {} | type: {}",
                body.get("senderId"), body.get("conversationId"), type);
        Message result = messagingService.sendMessage(
                body.get("senderId"),
                body.get("conversationId"),
                body.get("content"),
                type);
        log.debug("MSG_CTRL - POST /api/messaging/messages RESPONSE: 200 OK | id: {}", result.getId());
        return ResponseEntity.ok(result);
    }

    @GetMapping("/messages/{conversationId}")
    public ResponseEntity<Page<Message>> getMessages(
            @PathVariable String conversationId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "30") int size) {
        log.debug("MSG_CTRL - GET /api/messaging/messages/{} | page: {} | size: {}", conversationId, page, size);
        Page<Message> result = messagingService.getMessages(conversationId, page, size);
        log.debug("MSG_CTRL - GET /api/messaging/messages/{} RESPONSE: 200 OK | count: {}",
                conversationId, result.getNumberOfElements());
        return ResponseEntity.ok(result);
    }

    @PostMapping("/messages/{conversationId}/read")
    public ResponseEntity<Void> markAsRead(
            @PathVariable String conversationId,
            @RequestBody Map<String, String> body) {
        log.debug("MSG_CTRL - POST /api/messaging/messages/{}/read | userId: {}", conversationId, body.get("userId"));
        messagingService.markAsRead(conversationId, body.get("userId"));
        log.debug("MSG_CTRL - POST /api/messaging/messages/{}/read RESPONSE: 200 OK", conversationId);
        return ResponseEntity.ok().build();
    }
}
