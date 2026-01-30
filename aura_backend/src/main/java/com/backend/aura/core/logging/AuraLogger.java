package com.backend.aura.core.logging;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

@Component
@Slf4j
public class AuraLogger {

    public void appStarted() {
        log.info("[SYSTEM] Application started successfully");
    }

    public void apiRequest(String method, String path) {
        log.info("[API] {} {}", method, path);
    }

    public void apiSuccess(String path, int status) {
        log.info("[API] {} completed with status {}", path, status);
    }

    public void apiError(String path, String error) {
        log.error("[API] {} failed: {}", path, error);
    }

    public void sosTriggered(String userId, String eventId) {
        log.info("[SOS] Triggered by user: {} event: {}", userId, eventId);
    }

    public void sosResolved(String eventId, String resolvedBy) {
        log.info("[SOS] Resolved event: {} by: {}", eventId, resolvedBy);
    }

    public void postCreated(String userId, String postId) {
        log.info("[POST] Created by user: {} post: {}", userId, postId);
    }

    public void commentCreated(String userId, String postId, String commentId) {
        log.info("[COMMENT] Created by user: {} on post: {} comment: {}", userId, postId, commentId);
    }

    public void emailSent(String type, String recipient) {
        log.info("[EMAIL] {} sent to: {}", type, recipient);
    }

    public void emailFailed(String type, String recipient, String error) {
        log.error("[EMAIL] {} failed for: {} error: {}", type, recipient, error);
    }

    public void blockchainWriteSuccess(String eventId, String blockHash) {
        log.info("[BLOCKCHAIN] SOS event: {} written to block: {}", eventId, blockHash);
    }

    public void blockchainWriteFailed(String eventId, String error) {
        log.error("[BLOCKCHAIN] Failed to write event: {} error: {}", eventId, error);
    }

    public void offlineSyncReceived(String userId, int itemCount) {
        log.info("[SYNC] Received {} items from user: {}", itemCount, userId);
    }

    public void translationRequested(String contentId) {
        log.info("[TRANSLATION] Requested for: {}", contentId);
    }

    public void translationCompleted(String contentId, String language) {
        log.info("[TRANSLATION] Completed for: {} detected: {}", contentId, language);
    }

    public void translationFailed(String contentId) {
        log.error("[TRANSLATION] Failed for: {}", contentId);
    }

    public void userLogin(String userId) {
        log.info("[AUTH] User logged in: {}", userId);
    }

    public void userLogout(String userId) {
        log.info("[AUTH] User logged out: {}", userId);
    }

    public void profileUpdated(String userId, String field) {
        log.info("[PROFILE] User: {} updated: {}", userId, field);
    }
}
