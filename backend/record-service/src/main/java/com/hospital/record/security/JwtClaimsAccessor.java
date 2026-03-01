package com.hospital.record.security;

import com.hospital.common.security.JwtClaimKeys;
import io.jsonwebtoken.Claims;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.Optional;

/**
 * Minimal helper to read standardized JWT claims from the current {@link org.springframework.security.core.context.SecurityContext}.
 */
public final class JwtClaimsAccessor {

    private JwtClaimsAccessor() {
    }

    public static Optional<Claims> currentClaims() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null) {
            return Optional.empty();
        }
        Object principal = authentication.getPrincipal();
        if (principal instanceof Claims claims) {
            return Optional.of(claims);
        }
        return Optional.empty();
    }

    public static Optional<String> userId() {
        return currentClaims().map(c -> c.get(JwtClaimKeys.USER_ID, String.class));
    }

    public static Optional<String> role() {
        return currentClaims().map(c -> c.get(JwtClaimKeys.ROLE, String.class));
    }

    public static Optional<String> patientId() {
        return currentClaims().map(c -> c.get(JwtClaimKeys.PATIENT_ID, String.class));
    }

    public static Optional<String> hospitalId() {
        return currentClaims().map(c -> c.get(JwtClaimKeys.HOSPITAL_ID, String.class));
    }
}
