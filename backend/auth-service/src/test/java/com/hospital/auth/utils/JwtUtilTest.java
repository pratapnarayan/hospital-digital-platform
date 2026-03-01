package com.hospital.auth.utils;

import com.hospital.auth.model.User;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.junit.jupiter.api.Test;

import java.nio.charset.StandardCharsets;

import static org.junit.jupiter.api.Assertions.*;

class JwtUtilTest {

    // Must mirror the secret in JwtUtil (MVP setup).
    private static final String SECRET = "secret-key-must-be-at-least-32-bytes-long-for-hs256";

    @Test
    void generateToken_forDoctor_allowsMissingPatientId() {
        JwtUtil jwtUtil = new JwtUtil();

        User user = new User();
        user.setId("u-1");
        user.setUsername("doctor@hospital.test");
        user.setRole("DOCTOR");
        user.setPatientId(null);
        user.setHospitalId("h-1");

        String token = jwtUtil.generateToken(user);
        assertNotNull(token);

        Claims claims = Jwts.parserBuilder()
                .setSigningKey(Keys.hmacShaKeyFor(SECRET.getBytes(StandardCharsets.UTF_8)))
                .build()
                .parseClaimsJws(token)
                .getBody();

        assertEquals("doctor@hospital.test", claims.getSubject());
        assertEquals("u-1", claims.get("userId", String.class));
        assertEquals("DOCTOR", claims.get("role", String.class));
        assertEquals("h-1", claims.get("hospitalId", String.class));
        // patientId is allowed to be null for non-PATIENT roles.
        assertNull(claims.get("patientId"));
    }

    @Test
    void generateToken_forPatient_requiresPatientId() {
        JwtUtil jwtUtil = new JwtUtil();

        User user = new User();
        user.setId("u-2");
        user.setUsername("patient@hospital.test");
        user.setRole("PATIENT");
        user.setPatientId(" ");

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> jwtUtil.generateToken(user));
        assertTrue(ex.getMessage().toLowerCase().contains("patientid"));
    }
}
