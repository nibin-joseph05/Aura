package com.backend.aura.config.security;

import com.backend.aura.modules.auth.firebase.filter.FirebaseAuthFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

        private final FirebaseAuthFilter firebaseAuthFilter;

        public SecurityConfig(FirebaseAuthFilter firebaseAuthFilter) {
                this.firebaseAuthFilter = firebaseAuthFilter;
        }

        @Bean
        public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {

                http
                                .csrf(AbstractHttpConfigurer::disable)
                                .cors(cors -> {
                                })

                                .httpBasic(AbstractHttpConfigurer::disable)
                                .formLogin(AbstractHttpConfigurer::disable)

                                .authorizeHttpRequests(auth -> auth
                                                .requestMatchers(
                                                                "/api/health/**",
                                                                "/api/auth/**",
                                                                "/api/admin/login",
                                                                "/api/admin/register",
                                                                "/api/admin/current",
                                                                "/api/user/**",
                                                                "/api/upload/**",
                                                                "/uploads/**")
                                                .permitAll()
                                                .anyRequest().authenticated())

                                .addFilterBefore(
                                                firebaseAuthFilter,
                                                UsernamePasswordAuthenticationFilter.class);

                return http.build();
        }
}
