package com.hospital.auth.utils;

import com.hospital.auth.model.User;
import com.hospital.common.security.JwtClaimKeys;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.util.Date;

@Component
public class JwtUtil {
    private static final long ONE_DAY_MILLIS = 86_400_000L;

    private final String SECRET = "secret-key-must-be-at-least-32-bytes-long-for-hs256"; // Use a strong secret in production

    public String generateToken(User user) {
        // Required contract fields
        final String userId = user.getId();
        final String role = user.getRole();

        // patientId is mandatory for PATIENT role. For non-PATIENT roles it may be null/blank.
        final String patientId = user.getPatientId();
        if ("PATIENT".equalsIgnoreCase(role) && (patientId == null || patientId.isBlank())) {
            // Do not 500 the login endpoint due to inconsistent seed data; fail fast with a clear message.
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
                .signWith(Keys.hmacShaKeyFor(SECRET.getBytes(StandardCharsets.UTF_8)), SignatureAlgorithm.HS256)
                .compact();
    }
}
