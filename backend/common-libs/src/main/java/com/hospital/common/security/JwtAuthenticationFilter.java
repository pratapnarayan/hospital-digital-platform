package com.hospital.common.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jws;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Collections;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    // NOTE: For this MVP, we mirror auth-service's HS256 secret.
    // In production, externalize this and/or share via configuration management.
    private static final String SECRET = "secret-key-must-be-at-least-32-bytes-long-for-hs256";

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        final String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            final String token = authHeader.substring("Bearer ".length()).trim();
            if (!token.isEmpty()) {
                try {
                    Jws<Claims> parsed = Jwts.parserBuilder()
                            .setSigningKey(Keys.hmacShaKeyFor(SECRET.getBytes(StandardCharsets.UTF_8)))
                            .build()
                            .parseClaimsJws(token);

                    Claims claims = parsed.getBody();

                    // Keep authorities empty for now (non-goal: RBAC enforcement).
                    UsernamePasswordAuthenticationToken authentication =
                            new UsernamePasswordAuthenticationToken(claims, null, Collections.emptyList());

                    SecurityContextHolder.getContext().setAuthentication(authentication);
                } catch (JwtException ex) {
                    // Invalid/expired token: ignore and continue unauthenticated (do not break endpoints).
                    SecurityContextHolder.clearContext();
                }
            }
        }

        filterChain.doFilter(request, response);
    }
}
