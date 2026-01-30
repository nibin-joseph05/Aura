package com.backend.aura.modules.blockchain.service;

import com.backend.aura.core.logging.AuraLogger;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class BlockchainService {

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;
    private final AuraLogger auraLogger;

    @Value("${blockchain.service.url:http://localhost:8090}")
    private String blockchainUrl;

    @Value("${blockchain.enabled:false}")
    private boolean blockchainEnabled;

    public Optional<BlockchainResult> writeSosEvent(String eventId, String userId, Double latitude, Double longitude) {
        if (!blockchainEnabled) {
            log.info("Blockchain disabled, skipping write for event: {}", eventId);
            return Optional.empty();
        }

        try {
            String url = blockchainUrl + "/block";

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            Map<String, Object> requestBody = Map.of(
                    "eventId", eventId,
                    "userId", userId,
                    "latitude", latitude != null ? latitude : 0.0,
                    "longitude", longitude != null ? longitude : 0.0);

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);
            ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.POST, entity, String.class);

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                JsonNode json = objectMapper.readTree(response.getBody());
                if (json.path("success").asBoolean()) {
                    String blockHash = json.path("blockHash").asText();
                    long blockIndex = json.path("blockIndex").asLong();
                    auraLogger.blockchainWriteSuccess(eventId, blockHash);
                    return Optional.of(new BlockchainResult(blockHash, blockIndex));
                }
            }

            auraLogger.blockchainWriteFailed(eventId, "Non-success response");
            return Optional.empty();

        } catch (Exception e) {
            auraLogger.blockchainWriteFailed(eventId, e.getMessage());
            log.error("Blockchain write failed for event {}: {}", eventId, e.getMessage());
            return Optional.empty();
        }
    }

    public boolean validateChain() {
        if (!blockchainEnabled) {
            return true;
        }

        try {
            String url = blockchainUrl + "/validate";
            ResponseEntity<String> response = restTemplate.getForEntity(url, String.class);
            if (response.getBody() != null) {
                JsonNode json = objectMapper.readTree(response.getBody());
                return json.path("valid").asBoolean();
            }
        } catch (Exception e) {
            log.error("Blockchain validation failed: {}", e.getMessage());
        }
        return false;
    }

    public record BlockchainResult(String blockHash, long blockIndex) {
    }
}
