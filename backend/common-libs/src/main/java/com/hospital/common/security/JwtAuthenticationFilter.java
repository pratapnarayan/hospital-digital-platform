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
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Collections;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    /**
     * Loaded from jwt.secret in each consuming service's application.yml, or from the
     * JWT_SECRET environment variable. Must match the secret used by auth-service to
     * sign tokens — all services share the same HS256 key.
     *
     * Default value is for local development only and must be overridden in production.
     */
    @Value("${jwt.secret:dev-secret-key-must-be-at-least-32-bytes!!}")
    private String secret;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {

        final String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            final String token = authHeader.substring("Bearer ".length()).trim();
            if (!token.isEmpty()) {
                try {
                    Jws<Claims> parsed = Jwts.parserBuilder()
                            .setSigningKey(Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8)))
                            .build()
                            .parseClaimsJws(token);

                    Claims claims = parsed.getBody();

                    UsernamePasswordAuthenticationToken authentication =
                            new UsernamePasswordAuthenticationToken(claims, null, Collections.emptyList());
                    SecurityContextHolder.getContext().setAuthentication(authentication);

                } catch (JwtException ex) {
                    // Invalid or expired token — clear context and continue unauthenticated.
                    SecurityContextHolder.clearContext();
                }
            }
        }

        filterChain.doFilter(request, response);
    }
}
