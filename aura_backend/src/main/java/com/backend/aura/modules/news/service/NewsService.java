package com.backend.aura.modules.news.service;

import com.backend.aura.modules.news.dto.NewsArticleDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class NewsService {

    @Value("${news.api.key}")
    private String newsApiKey;

    private final RestTemplate restTemplate;

    private static final String EVENT_REGISTRY_URL = "https://eventregistry.org/api/v1/article/getArticles";

    public List<NewsArticleDTO> getWellnessNews(String query, int pageSize) {
        return fetchArticles(
                query != null && !query.isBlank() ? query : "health",
                pageSize);
    }

    public List<NewsArticleDTO> getHeadlineNews(int pageSize) {
        return fetchArticles("health", pageSize);
    }

    @SuppressWarnings("unchecked")
    private List<NewsArticleDTO> fetchArticles(String keyword, int pageSize) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            Map<String, Object> body = new HashMap<>();
            body.put("action", "getArticles");
            body.put("keyword", keyword);
            body.put("articlesPage", 1);
            body.put("articlesCount", Math.min(pageSize, 20));
            body.put("articlesSortBy", "date");
            body.put("articlesSortByAsc", false);
            body.put("articlesArticleBodyLen", 600);
            body.put("resultType", "articles");
            body.put("lang", "eng");
            body.put("apiKey", newsApiKey);

            log.debug("NEWS_SERVICE - Sending request to Event Registry: keyword={}, pageSize={}", keyword, pageSize);

            HttpEntity<Map<String, Object>> request = new HttpEntity<>(body, headers);
            ResponseEntity<Map> response = restTemplate.postForEntity(
                    EVENT_REGISTRY_URL, request, Map.class);

            if (response.getBody() == null) {
                log.warn("NEWS_SERVICE - Event Registry returned null body");
                return List.of();
            }

            Map<String, Object> responseBody = response.getBody();
            log.debug("NEWS_SERVICE - Event Registry response keys: {}", responseBody.keySet());

            if (responseBody.containsKey("error")) {
                log.error("NEWS_SERVICE - Event Registry error: {}", responseBody.get("error"));
                return List.of();
            }

            if (responseBody.containsKey("warning")) {
                log.warn("NEWS_SERVICE - Event Registry warning: {}", responseBody.get("warning"));
            }

            Map<String, Object> articles = (Map<String, Object>) responseBody.get("articles");
            if (articles == null) {
                log.warn("NEWS_SERVICE - No 'articles' key in response. Keys were: {}", responseBody.keySet());
                return List.of();
            }

            log.debug("NEWS_SERVICE - articles keys: {}", articles.keySet());
            Object totalResults = articles.get("totalResults");
            log.debug("NEWS_SERVICE - totalResults: {}", totalResults);

            List<Map<String, Object>> results = (List<Map<String, Object>>) articles.get("results");
            if (results == null || results.isEmpty()) {
                log.warn("NEWS_SERVICE - No results returned. totalResults={}", totalResults);
                return List.of();
            }

            log.info("NEWS_SERVICE - Got {} articles from Event Registry", results.size());

            List<NewsArticleDTO> dtos = new ArrayList<>();
            for (Map<String, Object> article : results) {
                String title = (String) article.get("title");
                if (title == null || title.isBlank())
                    continue;

                Map<String, Object> source = (Map<String, Object>) article.get("source");
                String sourceName = source != null ? (String) source.get("title") : null;

                dtos.add(NewsArticleDTO.builder()
                        .source(sourceName)
                        .author(null)
                        .title(title)
                        .description((String) article.get("body"))
                        .url((String) article.get("url"))
                        .imageUrl((String) article.get("image"))
                        .publishedAt((String) article.get("dateTimePub"))
                        .build());
            }
            return dtos;

        } catch (Exception e) {
            log.error("NEWS_SERVICE - Failed to fetch articles: {}", e.getMessage(), e);
            return List.of();
        }
    }
}
