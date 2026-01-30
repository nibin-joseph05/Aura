package com.backend.aura.modules.translation.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;

@Configuration
public class TranslationConfig {

    @Bean
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }
}
