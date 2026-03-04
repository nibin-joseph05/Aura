package com.backend.aura.modules.news.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class NewsArticleDTO {
    private String source;
    private String author;
    private String title;
    private String description;
    private String url;
    private String imageUrl;
    private String publishedAt;
}
