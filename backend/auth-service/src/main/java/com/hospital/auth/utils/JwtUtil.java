package com.hospital.auth.utils;

import com.hospital.auth.model.User;
import com.hospital.common.security.JwtClaimKeys;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.util.Date;

@Component
public class JwtUtil {
    private static final long ONE_DAY_MILLIS = 86_400_000L;

    /**
     * Loaded from application.yml (jwt.secret) or the JWT_SECRET environment variable.
     * Must be at least 32 characters for HS256.
     * In production: set via a secrets manager (AWS Secrets Manager, Vault, etc.)
     * and inject as an env var — never commit the real value to source control.
     */
    @Value("${jwt.secret}")
    private String secret;

    public String generateToken(User user) {
        final String userId = user.getId();
        final String role = user.getRole();
        final String patientId = user.getPatientId();

        // patientId is mandatory for PATIENT role. Fail fast so login returns a
        // meaningful error rather than issuing a token with a missing claim.
        if ("PATIENT".equalsIgnoreCase(role) && (patientId == null || patientId.isBlank())) {
            throw new IllegalArgumentException("patientId must be present for PATIENT role");
        }

        final String hospitalId = user.getHospitalId();
        final Date issuedAt = new Date();
        final Date expiration = new Date(System.currentTimeMillis() + ONE_DAY_MILLIS);

        return Jwts.builder()
                .setSubject(user.getUsername())
                .claim(JwtClaimKeys.USER_ID, userId)
                .claim(JwtClaimKeys.ROLE, role)
                .claim(JwtClaimKeys.PATIENT_ID, patientId)
                .claim(JwtClaimKeys.HOSPITAL_ID, hospitalId)
                .setIssuedAt(issuedAt)
                .setExpiration(expiration)
                .signWith(Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8)), SignatureAlgorithm.HS256)
                .compact();
    }
}
