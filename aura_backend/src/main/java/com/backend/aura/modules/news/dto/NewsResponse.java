package com.backend.aura.modules.news.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class NewsResponse {
    private String status;
    private int totalResults;
    private List<NewsArticle> articles;

    @Data
    @Builder
    @AllArgsConstructor
    @NoArgsConstructor
    public static class NewsArticle {
        private Source source;
        private String author;
        private String title;
        private String description;
        private String url;
        private String urlToImage;
        private String publishedAt;
        private String content;
    }

    @Data
    @Builder
    @AllArgsConstructor
    @NoArgsConstructor
    public static class Source {
        private String id;
        private String name;
    }
}
