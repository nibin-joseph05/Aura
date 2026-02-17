package com.backend.aura.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.web.util.ContentCachingRequestWrapper;
import org.springframework.web.util.ContentCachingResponseWrapper;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class RequestLoggingFilter extends OncePerRequestFilter {

    private static final Logger log = LoggerFactory.getLogger(RequestLoggingFilter.class);

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {

        ContentCachingRequestWrapper wrappedRequest = new ContentCachingRequestWrapper(request);
        ContentCachingResponseWrapper wrappedResponse = new ContentCachingResponseWrapper(response);

        String method = request.getMethod();
        String path = request.getRequestURI();
        String query = request.getQueryString();
        String fullPath = query != null ? path + "?" + query : path;

        long startTime = System.currentTimeMillis();

        log.debug("============================================================");
        log.debug(">>> REQUEST  - {} {}", method, fullPath);
        log.debug(">>> Auth     - {}", request.getHeader("Authorization") != null ? "Bearer ***" : "none");

        try {
            filterChain.doFilter(wrappedRequest, wrappedResponse);
        } finally {
            long duration = System.currentTimeMillis() - startTime;
            int status = wrappedResponse.getStatus();

            if ("POST".equals(method) || "PUT".equals(method) || "PATCH".equals(method)) {
                byte[] requestBody = wrappedRequest.getContentAsByteArray();
                if (requestBody.length > 0) {
                    String body = new String(requestBody, StandardCharsets.UTF_8);
                    body = body.replaceAll("\"password\"\\s*:\\s*\"[^\"]*\"", "\"password\":\"***\"");
                    log.debug(">>> Body     - {}", truncate(body, 500));
                }
            }

            byte[] responseBody = wrappedResponse.getContentAsByteArray();
            if (responseBody.length > 0) {
                String resBody = new String(responseBody, StandardCharsets.UTF_8);
                log.debug("<<< RESPONSE - {} {} | status={} | {}ms", method, path, status, duration);
                log.debug("<<< Body     - {}", truncate(resBody, 500));
            } else {
                log.debug("<<< RESPONSE - {} {} | status={} | {}ms | (empty body)", method, path, status, duration);
            }
            log.debug("============================================================");

            wrappedResponse.copyBodyToResponse();
        }
    }

    private String truncate(String s, int maxLen) {
        if (s == null)
            return "null";
        return s.length() <= maxLen ? s : s.substring(0, maxLen) + "...(truncated)";
    }
}
