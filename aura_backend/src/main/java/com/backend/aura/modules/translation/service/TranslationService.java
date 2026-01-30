package com.backend.aura.modules.translation.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class TranslationService {

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    @Value("${gemini.api.key:}")
    private String apiKey;

    @Value("${gemini.api.url:https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent}")
    private String apiUrl;

    public Optional<TranslationResult> translateToEnglish(String text) {
        if (text == null || text.isBlank()) {
            return Optional.empty();
        }

        if (apiKey == null || apiKey.isBlank()) {
            log.warn("Gemini API key not configured");
            return Optional.empty();
        }

        try {
            String prompt = buildTranslationPrompt(text);
            String response = callGeminiApi(prompt);
            return parseTranslationResponse(response, text);
        } catch (Exception e) {
            log.error("Translation failed: {}", e.getMessage());
            return Optional.empty();
        }
    }

    private String buildTranslationPrompt(String text) {
        return String.format(
                "Detect the language of the following text and translate it to English. " +
                        "Respond ONLY with a JSON object in this exact format: " +
                        "{\"detectedLanguage\": \"language_code\", \"translatedText\": \"the translation\", \"isEnglish\": true/false}. "
                        +
                        "If the text is already in English, set isEnglish to true and keep translatedText the same. " +
                        "Text to translate: \"%s\"",
                text.replace("\"", "\\\""));
    }

    private String callGeminiApi(String prompt) {
        String url = apiUrl + "?key=" + apiKey;

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        Map<String, Object> requestBody = Map.of(
                "contents", List.of(
                        Map.of("parts", List.of(Map.of("text", prompt)))),
                "generationConfig", Map.of(
                        "temperature", 0.1,
                        "maxOutputTokens", 1024));

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);
        ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.POST, entity, String.class);

        return response.getBody();
    }

    private Optional<TranslationResult> parseTranslationResponse(String response, String originalText) {
        try {
            JsonNode root = objectMapper.readTree(response);
            JsonNode candidates = root.path("candidates");
            if (candidates.isEmpty()) {
                return Optional.empty();
            }

            String generatedText = candidates.get(0)
                    .path("content")
                    .path("parts")
                    .get(0)
                    .path("text")
                    .asText();

            String jsonStr = extractJsonFromResponse(generatedText);
            JsonNode translationJson = objectMapper.readTree(jsonStr);

            String detectedLanguage = translationJson.path("detectedLanguage").asText("unknown");
            String translatedText = translationJson.path("translatedText").asText(originalText);
            boolean isEnglish = translationJson.path("isEnglish").asBoolean(false);

            return Optional.of(TranslationResult.builder()
                    .originalText(originalText)
                    .translatedText(translatedText)
                    .detectedLanguage(detectedLanguage)
                    .isEnglish(isEnglish)
                    .build());

        } catch (Exception e) {
            log.error("Failed to parse translation response: {}", e.getMessage());
            return Optional.empty();
        }
    }

    private String extractJsonFromResponse(String text) {
        int start = text.indexOf("{");
        int end = text.lastIndexOf("}");
        if (start != -1 && end != -1 && end > start) {
            return text.substring(start, end + 1);
        }
        return text;
    }

    @lombok.Data
    @lombok.Builder
    @lombok.NoArgsConstructor
    @lombok.AllArgsConstructor
    public static class TranslationResult {
        private String originalText;
        private String translatedText;
        private String detectedLanguage;
        private boolean isEnglish;
    }
}
