package com.backend.aura.modules.auth.firebase.filter;

import com.backend.aura.modules.auth.firebase.context.AuthenticatedUserContext;
import com.backend.aura.modules.auth.firebase.service.FirebaseAuthService;
import com.backend.aura.modules.user.repository.UserRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;

@Component
public class FirebaseAuthFilter extends OncePerRequestFilter {

    private static final Logger log = LoggerFactory.getLogger(FirebaseAuthFilter.class);

    private final FirebaseAuthService firebaseAuthService;
    private final UserRepository userRepository;

    public FirebaseAuthFilter(FirebaseAuthService firebaseAuthService, UserRepository userRepository) {
        this.firebaseAuthService = firebaseAuthService;
        this.userRepository = userRepository;
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {

        String method = request.getMethod();
        String path = request.getRequestURI();
        String authHeader = request.getHeader("Authorization");
        String xUserId = request.getHeader("X-User-Id");

        log.debug("------------------------------------------------------------");
        log.debug("FILTER - {} {} | Auth header present: {}", method, path, authHeader != null);

        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            log.debug("FILTER - Verifying Firebase token (length: {})", token.length());

            try {
                AuthenticatedUserContext authContext = firebaseAuthService.verifyTokenAndSyncUser(token);
                request.setAttribute("AUTH_CONTEXT", authContext);

                UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                        authContext.getUid(), null, Collections.emptyList());
                SecurityContextHolder.getContext().setAuthentication(authentication);

                log.debug("FILTER - Auth SUCCESS | uid: {} | email: {} | phone: {}",
                        authContext.getUid(), authContext.getEmail(), authContext.getPhone());
            } catch (Exception e) {
                log.debug("FILTER - Auth FAILED | error: {}", e.getMessage());
            }
        } else if (xUserId != null && !xUserId.isBlank()) {
            log.debug("FILTER - No Bearer token, checking X-User-Id: {}", xUserId);
            userRepository.findByUid(xUserId).ifPresent(user -> {
                AuthenticatedUserContext authContext = new AuthenticatedUserContext(
                        user.getUid(),
                        user.getEmail(),
                        user.getPhone(),
                        user.getSignupMethod() != null ? user.getSignupMethod().name() : "EMAIL");
                request.setAttribute("AUTH_CONTEXT", authContext);

                UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                        xUserId, null, Collections.emptyList());
                SecurityContextHolder.getContext().setAuthentication(authentication);
                log.debug("FILTER - X-User-Id auth SUCCESS | uid: {} | email: {}",
                        xUserId, authContext.getEmail());
            });

            if (SecurityContextHolder.getContext().getAuthentication() == null) {
                log.debug("FILTER - X-User-Id uid not found in DB: {}", xUserId);
            }
        } else {
            log.debug("FILTER - No Bearer token, proceeding without auth");
        }

        filterChain.doFilter(request, response);
        log.debug("FILTER - Response status: {} for {} {}", response.getStatus(), method, path);
        log.debug("------------------------------------------------------------");
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String path = request.getRequestURI();

        if (path.equals("/api/auth/me")) {
            return false;
        }

        boolean skip = path.startsWith("/api/health")
                || path.startsWith("/api/auth")
                || path.startsWith("/api/admin")
                || path.startsWith("/api/upload")
                || path.equals("/api/user/password/change");

        if (skip) {
            log.debug("FILTER - SKIPPING filter for path: {}", path);
        }

        return skip;
    }
}
