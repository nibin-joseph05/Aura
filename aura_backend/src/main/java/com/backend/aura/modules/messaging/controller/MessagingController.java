package com.backend.aura.modules.messaging.controller;

import com.backend.aura.modules.messaging.model.Conversation;
import com.backend.aura.modules.messaging.model.FollowRelationship;
import com.backend.aura.modules.messaging.model.Message;
import com.backend.aura.modules.messaging.service.MessagingService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/messaging")
@RequiredArgsConstructor
public class MessagingController {

    private final MessagingService messagingService;

    @PostMapping("/follow/request")
    public ResponseEntity<FollowRelationship> sendFollowRequest(@RequestBody Map<String, String> body) {
        return ResponseEntity.ok(
                messagingService.sendFollowRequest(body.get("fromUserId"), body.get("toUserId")));
    }

    @PostMapping("/follow/accept/{requestId}")
    public ResponseEntity<FollowRelationship> acceptFollow(@PathVariable String requestId) {
        return ResponseEntity.ok(messagingService.acceptFollowRequest(requestId));
    }

    @PostMapping("/follow/reject/{requestId}")
    public ResponseEntity<Void> rejectFollow(@PathVariable String requestId) {
        messagingService.rejectFollowRequest(requestId);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/follow/unfollow")
    public ResponseEntity<Void> unfollow(@RequestBody Map<String, String> body) {
        messagingService.unfollow(body.get("fromUserId"), body.get("toUserId"));
        return ResponseEntity.ok().build();
    }

    @GetMapping("/follow/pending/{userId}")
    public ResponseEntity<Page<FollowRelationship>> getPendingRequests(
            @PathVariable String userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(messagingService.getPendingFollowRequests(userId, page, size));
    }

    @GetMapping("/follow/count/{userId}")
    public ResponseEntity<Map<String, Long>> getPendingCount(@PathVariable String userId) {
        return ResponseEntity.ok(Map.of("count", messagingService.getPendingFollowCount(userId)));
    }

    @GetMapping("/follow/followers/{userId}")
    public ResponseEntity<Page<FollowRelationship>> getFollowers(
            @PathVariable String userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(messagingService.getFollowers(userId, page, size));
    }

    @GetMapping("/follow/following/{userId}")
    public ResponseEntity<Page<FollowRelationship>> getFollowing(
            @PathVariable String userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(messagingService.getFollowing(userId, page, size));
    }

    @GetMapping("/follow/status")
    public ResponseEntity<Map<String, Object>> getFollowStatus(
            @RequestParam String fromUserId,
            @RequestParam String toUserId) {
        return ResponseEntity.ok(messagingService.getFollowStatus(fromUserId, toUserId));
    }

    @PostMapping("/conversations")
    public ResponseEntity<Conversation> getOrCreateConversation(@RequestBody Map<String, String> body) {
        return ResponseEntity.ok(
                messagingService.getOrCreateConversation(body.get("userA"), body.get("userB")));
    }

    @GetMapping("/conversations/{userId}")
    public ResponseEntity<Page<Conversation>> getConversations(
            @PathVariable String userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(messagingService.getConversations(userId, page, size));
    }

    @PostMapping("/messages")
    public ResponseEntity<Message> sendMessage(@RequestBody Map<String, String> body) {
        Message.MessageType type = Message.MessageType.valueOf(
                body.getOrDefault("type", "TEXT"));
        return ResponseEntity.ok(
                messagingService.sendMessage(
                        body.get("senderId"),
                        body.get("conversationId"),
                        body.get("content"),
                        type));
    }

    @GetMapping("/messages/{conversationId}")
    public ResponseEntity<Page<Message>> getMessages(
            @PathVariable String conversationId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "30") int size) {
        return ResponseEntity.ok(messagingService.getMessages(conversationId, page, size));
    }

    @PostMapping("/messages/{conversationId}/read")
    public ResponseEntity<Void> markAsRead(
            @PathVariable String conversationId,
            @RequestBody Map<String, String> body) {
        messagingService.markAsRead(conversationId, body.get("userId"));
        return ResponseEntity.ok().build();
    }
}
