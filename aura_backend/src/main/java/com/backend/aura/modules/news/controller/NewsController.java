package com.backend.aura.modules.news.controller;

import com.backend.aura.modules.common.dto.ApiResponse;
import com.backend.aura.modules.news.dto.NewsArticleDTO;
import com.backend.aura.modules.news.service.NewsService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/news")
@RequiredArgsConstructor
public class NewsController {

    private final NewsService newsService;

    @GetMapping("/wellness")
    public ResponseEntity<ApiResponse<List<NewsArticleDTO>>> getWellnessNews(
            @RequestParam(required = false) String query,
            @RequestParam(defaultValue = "10") int pageSize) {
        List<NewsArticleDTO> articles = newsService.getWellnessNews(query, pageSize);
        return ResponseEntity.ok(ApiResponse.success(articles));
    }

    @GetMapping("/headlines")
    public ResponseEntity<ApiResponse<List<NewsArticleDTO>>> getHealthHeadlines(
            @RequestParam(defaultValue = "10") int pageSize) {
        List<NewsArticleDTO> articles = newsService.getHeadlineNews(pageSize);
        return ResponseEntity.ok(ApiResponse.success(articles));
    }
}
